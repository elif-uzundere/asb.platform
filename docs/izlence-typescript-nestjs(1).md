# İzlence — TypeScript + NestJS + React Native + PostgreSQL
## ASB Platform — Modül-Önce Katmanlı Mimari, 2 Kişilik Paralel Çalışma Planı

| Alan | Değer |
|------|-------|
| **Backend** | Node.js 20 LTS + NestJS + TypeScript |
| **Frontend** | React Native (**Expo** — managed workflow) + TypeScript (iOS + Android), Web için `react-native-web` |
| **State management** | **Zustand** (kesinleşti — kurulumu/öğrenmesi hafif) |
| **HTTP client** | Axios (interceptor ile token yönetimi) |
| **Veritabanı** | PostgreSQL 16 |
| **ORM** | Prisma |
| **Dosya/fotoğraf depolama** | Yerel disk (Docker volume) — `FileStoragePort` arkasında soyutlanmış, ileride S3/MinIO'ya geçiş kod değişikliği gerektirmez |
| **Repo yapısı** | **Monorepo** (npm workspaces) — `packages/shared-types` ile backend↔frontend tip paylaşımı |
| **Admin paneli** | Ayrı uygulama değil — aynı React Native/Web uygulaması içinde **rol bazlı** ekstra menüler (`rol=admin` ise) |
| **API versiyonlama** | `/api/v1/...` — bkz. `teknikPlan.md` Bölüm 6 |
| **Mimari stil** | Modül-önce, değişken katman derinliği |
| **Ekip** | 2 kişi — **dikey bölünme (modül bazlı)**, bkz. Bölüm 6 — bu doküman kim-ne-yapıyor planını içerir |
| **İlerleme birimi** | Adım |
| **İlgili dokümanlar** | `isterler.md` (ne), `teknikPlan.md` (veri modeli + API referansı) |

---

## 1. Mimari Felsefe

NestJS zaten çekirdeğinde "modül" (`@Module()`) kavramını barındırıyor — bu yüzden **modül-önce yaklaşım burada Java'dakinden bile daha doğal.** Java tarafında Spring Modulith'in yaptığı işi, burada NestJS'in kendi modül sistemi + bir ESLint kuralı ile sağlıyoruz.

Aynı prensip: her modül kendi karmaşıklığına göre 2 veya 3 katmanlı olur, sabit bir sayı dayatılmaz (KISS).

| Modül | Karmaşıklık gerekçesi | Katman derinliği |
|-------|--------------------------|----------------------|
| `duyuru`, `banner`, `is-ortaklari` | Basit CRUD, tek kural (BR-4: sadece admin) | **2 katman:** `domain` + `adapters` |
| `auth` | Şifre hash, JWT, OAuth, e-posta doğrulama | **3 katman:** `domain` + `application` + `adapters` |
| `firma` | Onay akışı (BR-1), cascade (BR-6) | **3 katman** |
| `is-ilanlari` | Onaylı firma kontrolü (BR-2) | **3 katman** |
| `ikinci-el-pazar` | E-posta doğrulama şartı (BR-3), durum yönetimi (BR-8) | **3 katman** |
| `cookzone` | Çoklu entity + sipariş durum makinesi | **3 katman** |
| `acil-durum` | Zorunlu alan kombinasyonu (BR-5) | **3 katman** |
| `paket-teslimi`, `harita` | Basit durum takibi / coğrafi sorgu | **2 katman** |

### Neden `domain` katmanında NestJS decorator'ı olmaz

Bir NestJS projesinde en sık yapılan hata: her class'a refleks halinde `@Injectable()` yapıştırmak, servis içine hem iş kuralını hem Prisma çağrısını hem HTTP response şekillendirmeyi aynı yere yazmak. Bunun sonucu **framework'e kilitlenmiş, test edilemeyen kod** olur (Jest ile test etmek için tüm Nest test modülünü ayağa kaldırman gerekir).

Burada tercih: `domain` ve mümkün olduğunca `application` katmanındaki class'lar **saf TypeScript** olur, Nest decorator'ı taşımaz. NestJS'e bağlanma işi sadece `adapters` katmanında, **custom provider** (`useFactory`) ile yapılır:

```typescript
// application/is-ilani.service.ts — SAF TypeScript, Nest'i bilmez
export class IsIlaniService {
  constructor(
    private readonly isIlaniRepo: IsIlaniRepository,   // interface, implementasyon değil
    private readonly firmaSorgu: FirmaSorgulamaPort,   // başka modülün dışa açık arayüzü
  ) {}

  async yayinla(dto: IlanYayinlaDto): Promise<IsIlani> {
    const firmaOnayli = await this.firmaSorgu.isOnayli(dto.firmaId);  // BR-2
    if (!firmaOnayli) throw new FirmaOnayliDegilException();
    // ...
  }
}
```

```typescript
// is-ilanlari.module.ts — Nest'e bağlama burada olur
@Module({
  providers: [
    {
      provide: IsIlaniService,
      useFactory: (repo: IsIlaniRepository, firmaSorgu: FirmaSorgulamaPort) =>
        new IsIlaniService(repo, firmaSorgu),
      inject: [ISILANI_REPOSITORY_TOKEN, FIRMA_SORGULAMA_TOKEN],
    },
  ],
})
export class IsIlanlariModule {}
```

Bu sayede `IsIlaniService`'i test etmek için Nest'in test modülünü hiç ayağa kaldırmadan, düz `new IsIlaniService(sahteRepo, sahteFirmaSorgu)` ile test yazabilirsiniz — hızlı, framework'süz, saf unit test.

### Modül sınırlarını koruma — `eslint-plugin-boundaries`

Java tarafında Spring Modulith'in yaptığı "modüller birbirinin iç detayına erişemez" garantisini, burada bir ESLint kuralıyla sağlıyoruz:

```json
{
  "boundaries/element-types": [
    "error",
    {
      "default": "disallow",
      "rules": [
        { "from": "modules/*/domain", "allow": ["shared/domain"] },
        { "from": "modules/*/application", "allow": ["*/domain", "shared"] },
        { "from": "modules/*/adapters", "allow": ["*/domain", "*/application", "shared"] },
        { "from": "modules/is-ilanlari/*", "allow": ["modules/firma/adapters/public"] }
      ]
    }
  ]
}
```

Bu kural, "bir modülün `domain` klasörü başka bir modülün herhangi bir dosyasını import edemez" gibi ihlalleri **CI'da, her push'ta** otomatik yakalar — biri yanlışlıkla `isilani/domain` içinden `firma/adapters/persistence` import etmeye kalksa, pipeline kırmızıya döner.

---

## 2. Proje Yapısı — Monorepo (npm workspaces)

Repo yapısı kararı: **monorepo**. Gerekçe — `packages/shared-types` sayesinde backend'deki bir DTO değiştiğinde frontend derleme zamanında hata alır, ayrı repo'da bu tip paylaşımı için ekstra bir npm publish süreci gerekirdi.

```
asb-platform/                             # npm workspaces root
├── package.json                          # workspaces: ["packages/*"]
├── .github/workflows/ci.yml              # backend + mobile + shared-types tek pipeline'da
│
├── packages/
│   ├── shared-types/                     # ★ Backend ↔ Frontend arasında paylaşılan tipler
│   │   ├── src/
│   │   │   ├── auth.types.ts             # RegisterRequest, LoginResponse, ...
│   │   │   ├── firma.types.ts
│   │   │   ├── is-ilani.types.ts
│   │   │   └── ...
│   │   └── package.json                  # @asb/shared-types
│   │
│   ├── backend/                          # @asb/backend — NestJS
│   │   ├── src/
│   │   │   ├── shared/                   # Ortak — global filter, guard, Prisma servisi
│   │   │   │   ├── domain/
│   │   │   │   │   └── base-entity.ts    # id, createdAt gibi ortak alanlar
│   │   │   │   ├── infrastructure/
│   │   │   │   │   ├── prisma.service.ts
│   │   │   │   │   └── file-storage/
│   │   │   │   │       ├── file-storage.port.ts        # ★ Interface — Local mı S3 mü bilmez
│   │   │   │   │       └── local-file-storage.adapter.ts  # Şimdilik: yerel disk implementasyonu
│   │   │   │   └── web/
│   │   │   │       ├── global-exception.filter.ts
│   │   │   │       ├── api-response.dto.ts   # Standart response zarfı
│   │   │   │       └── jwt-auth.guard.ts
│   │   │   │
│   │   │   ├── modules/
│   │   │   │   ├── auth/
│   │   │   │   │   ├── domain/               # Kullanici entity (saf class), Email value object
│   │   │   │   │   ├── application/          # AuthService — kayıt/giriş akışı (saf TS)
│   │   │   │   │   ├── adapters/
│   │   │   │   │   │   ├── web/              # AuthController — @asb/shared-types DTO'larını kullanır
│   │   │   │   │   │   └── persistence/      # PrismaKullaniciRepository
│   │   │   │   │   └── auth.module.ts        # Nest'e bağlama — provider wiring burada
│   │   │   │   │
│   │   │   │   ├── firma/
│   │   │   │   │   ├── domain/               # Firma entity, OnayDurumu enum
│   │   │   │   │   ├── application/          # FirmaService — BR-1 (onay akışı)
│   │   │   │   │   ├── adapters/
│   │   │   │   │   │   ├── web/
│   │   │   │   │   │   ├── persistence/
│   │   │   │   │   │   └── public/           # ★ Dışa açık arayüz — başka modüller SADECE bunu import edebilir
│   │   │   │   │   │       └── firma-sorgulama.port.ts
│   │   │   │   │   └── firma.module.ts
│   │   │   │   │
│   │   │   │   ├── is-ilanlari/
│   │   │   │   │   ├── domain/
│   │   │   │   │   ├── application/          # BR-2 — firma modülünün public/ arayüzünü kullanır
│   │   │   │   │   ├── adapters/{web,persistence}/
│   │   │   │   │   └── is-ilanlari.module.ts
│   │   │   │   │
│   │   │   │   ├── ikinci-el-pazar/
│   │   │   │   │   ├── domain/
│   │   │   │   │   ├── application/          # BR-3, BR-8
│   │   │   │   │   ├── adapters/
│   │   │   │   │   │   ├── web/              # Fotoğraf yükleme endpoint'i — shared/FileStoragePort'u kullanır
│   │   │   │   │   │   └── persistence/
│   │   │   │   │   └── ikinci-el-pazar.module.ts
│   │   │   │   │
│   │   │   │   ├── cookzone/
│   │   │   │   │   ├── domain/               # Isletme, MenuOgesi, Siparis, SiparisKalemi
│   │   │   │   │   ├── application/
│   │   │   │   │   │   └── siparis-durum.service.ts   # Durum makinesi
│   │   │   │   │   ├── adapters/{web,persistence}/
│   │   │   │   │   └── cookzone.module.ts
│   │   │   │   │
│   │   │   │   ├── acil-durum/
│   │   │   │   │   ├── domain/
│   │   │   │   │   ├── application/          # BR-5
│   │   │   │   │   ├── adapters/{web,persistence}/
│   │   │   │   │   └── acil-durum.module.ts
│   │   │   │   │
│   │   │   │   ├── paket-teslimi/            # 2 katman — application yok
│   │   │   │   │   ├── domain/
│   │   │   │   │   ├── adapters/{web,persistence}/
│   │   │   │   │   └── paket-teslimi.module.ts
│   │   │   │   │
│   │   │   │   ├── harita/                   # 2 katman
│   │   │   │   │   ├── domain/
│   │   │   │   │   ├── adapters/{web,persistence}/
│   │   │   │   │   └── harita.module.ts
│   │   │   │   │
│   │   │   │   ├── duyuru/                   # 2 katman — BR-4
│   │   │   │   │   ├── domain/
│   │   │   │   │   ├── adapters/{web,persistence}/
│   │   │   │   │   └── duyuru.module.ts
│   │   │   │   │
│   │   │   │   ├── banner/                   # 2 katman
│   │   │   │   └── is-ortaklari/             # 2 katman
│   │   │   │
│   │   │   ├── app.module.ts                 # Tüm modülleri birleştirir, /api/v1 versiyonlama burada açılır
│   │   │   └── main.ts
│   │   │
│   │   ├── prisma/
│   │   │   ├── schema.prisma
│   │   │   ├── migrations/
│   │   │   └── seed.ts
│   │   │
│   │   ├── test/
│   │   │   ├── unit/                         # Her modülün application/domain testleri (saf, mock az)
│   │   │   └── e2e/                          # Controller + gerçek DB (Testcontainers)
│   │   │
│   │   ├── uploads/                          # Yerel dosya deposu (Docker volume ile kalıcı)
│   │   ├── .eslintrc.json                    # boundaries kuralları burada
│   │   └── package.json                      # @asb/backend
│   │
│   └── mobile/                               # @asb/mobile — Expo (React Native)
│       ├── app/                              # Expo Router — dosya bazlı sayfa yönlendirme
│       │   ├── (tabs)/                       # Bottom tab grubu: Ana Sayfa, Firmalar, Harita, Duyurular, Profil
│       │   └── (admin)/                      # ★ Sadece rol=admin girişte görünen ekstra sekme grubu
│       ├── src/
│       │   ├── core/
│       │   │   ├── api/                      # Axios client, interceptor — @asb/shared-types tiplerini kullanır
│       │   │   ├── stores/                   # Zustand store'ları
│       │   │   └── components/
│       │   └── features/
│       │       ├── auth/
│       │       ├── ana-sayfa/
│       │       ├── firmalar/
│       │       ├── is-ilanlari/
│       │       ├── ikinci-el-pazar/
│       │       └── ...
│       ├── app.json                          # Expo config
│       └── package.json                      # @asb/mobile
│
├── docker-compose.yml
├── docker-compose.prod.yml
└── README.md
```

### Admin paneli — nasıl "ayrı uygulama" olmadan çözülüyor

`Kullanici.rol === 'admin'` ile giriş yapan kullanıcı, aynı Expo uygulamasında `(admin)` route grubunu görür (Expo Router'ın grup mekanizmasıyla, bkz. `app/(admin)/`) — duyuru oluşturma, firma onaylama gibi ekranlar buraya eklenir. Web'de (`react-native-web`) bu aynı uygulama tarayıcıda açıldığında admin kullanıcı için otomatik olarak bu ekranlara erişebilir. Ayrı bir proje/deploy hattı yönetmek zorunda kalmazsınız.

### Dosya depolama — `FileStoragePort` deseni

İkinci el ilanı fotoğrafları için `shared/infrastructure/file-storage/file-storage.port.ts` bir interface tanımlar (`upload(file): Promise<string>` gibi). Şimdilik tek implementasyon **yerel disk** (`local-file-storage.adapter.ts`) — Docker volume ile container yeniden başlasa bile veri kaybolmaz. İleride S3/MinIO'ya geçmek istenirse, sadece yeni bir adapter yazılır (`s3-file-storage.adapter.ts`), `ikinci-el-pazar` modülünün hiçbir kodu değişmez — bu, Dependency Inversion ilkesinin pratikte ne kazandırdığının somut bir örneği.

### Modüller arası iletişim kuralı

`is-ilanlari` modülü, "bu firma onaylı mı?" sorusunu `firma` modülünün `adapters/persistence` katmanına doğrudan erişerek değil, `firma/adapters/public/firma-sorgulama.port.ts` üzerinden sorar. `firma` modülünün iç yapısı (Prisma sorguları, entity şekli) tamamen değişse bile, bu arayüz sabit kaldığı sürece `is-ilanlari` etkilenmez.

---

## 3. SOLID, KISS, DRY

### SOLID

| İlke | Karşılığı |
|------|-----------|
| **S**ingle Responsibility | Her modülün `application` servisi tek iş kuralı grubunu yönetir |
| **O**pen/Closed | Yeni bildirim kanalı, `shared` altına yeni bir port eklenerek yapılır, mevcut servisler değişmez |
| **L**iskov Substitution | `IsIlaniRepository` interface'inin test'teki sahte implementasyonu, prod'daki Prisma implementasyonunun yerine geçebilir |
| **I**nterface Segregation | Her modülün `adapters/public/` klasörü sadece gerçekten paylaşılan minimum arayüzü içerir |
| **D**ependency Inversion | `is-ilanlari`, `firma`'nın somut Prisma kodunu değil, soyut `FirmaSorgulamaPort`'unu bilir |

### KISS
- Katman derinliği modüle göre değişir — basit modüle (`duyuru`, `harita`) gereksiz `application` katmanı eklenmez
- `useFactory` ile manuel wiring sadece gerekli olduğunda kullanılır; basit modüllerde standart `@Injectable()` yeterli olabilir

### DRY
- `shared/web/api-response.dto.ts` ile tüm response'lar tek şablon kullanır
- `shared/domain/base-entity.ts` ile `id`/`createdAt` tekrar yazılmaz
- Prisma şeması tek dosyada (`schema.prisma`), her modül kendi tablosunu tanımlar ama migration tek pipeline'dan geçer

---

## 4. Veritabanı ve Migration

Şema `teknikPlan.md` Bölüm 4 ile birebir aynı. Migration: **Prisma Migrate** (`npx prisma migrate dev`), dosyalar `prisma/migrations/` altında otomatik üretilir.

---

## 5. React Native Tarafı — Nielsen'in 10 Kullanılabilirlik İlkesi

(UX prensipleri backend dilinden bağımsızdır — Java dosyasıyla aynı tablo)

| # | İlke | ASB Platform karşılığı |
|---|------|----------------------------|
| 1 | Sistem durumu görünürlüğü | `ActivityIndicator`, Cookzone sipariş durumu anlık |
| 2 | Gerçek dünya eşleşmesi | Tanıdık terimler ("Onayla" vb.) |
| 3 | Kullanıcı kontrolü | Geri dönülebilir form adımları (React Navigation), onay adımları |
| 4 | Tutarlılık | Sabit filtre konumu, sabit bottom tab |
| 5 | Hata önleme | Native date-picker, sayısal klavye kısıtı |
| 6 | Tanıma > hatırlama | Dropdown/Picker seçimler |
| 7 | Esneklik | Acil Durum tek dokunuşla |
| 8 | Minimalizm | Mockup'taki 8 modülün dışına çıkılmaz |
| 9 | Hata teşhisi | Anlaşılır Türkçe mesajlar (Toast/Snackbar) |
| 10 | Yardım | Tooltip, SSS |

### Klasör yapısı ve state management

Detaylı klasör ağacı Bölüm 2'de (`packages/mobile/`) — Expo Router ile dosya bazlı sayfa yönlendirme, `core/stores/` altında **Zustand** store'ları.

**Ortak tip paylaşımı — DRY'ın dil birliğiyle gelen ekstra faydası:** Backend ve frontend aynı dilde (TypeScript) olduğu için, DTO tiplerini `packages/shared-types` içinde tanımlayıp hem `packages/backend` hem `packages/mobile` projesinde import edebilirsiniz. Böylece "backend'de alan adı değişti ama frontend güncellemeyi unuttu" gibi hatalar **derleme zamanında** yakalanır — Java+Flutter kombinasyonunda bu imkan yoktu.

**Web desteği (`react-native-web`) için not:** Harita ve kamera gibi native modüller web'de farklı paket gerektirebilir; Expo'nun `Platform.OS === 'web'` kontrolü ile ayrı bileşen kullanılması Adım 14'te (Web uyarlaması) planlanmalı.

---

## 6. İki Kişilik Ekip — Neden burada tavsiye değişiyor

Java+Flutter'da "yatay bölünme" (biri hep backend, biri hep frontend) önermiştik çünkü Java ve Dart birbirinden çok uzak iki dünyaydı — aynı kişinin ikisini birden öğrenmesi ağır bir yükümlü. **TypeScript + React Native'de bu engel ortadan kalkıyor:** ikisi de aynı dil, aynı `npm` ekosistemi, hatta aynı IDE (VS Code) alışkanlıkları.

Bu yüzden burada **dikey bölünme (modül bazlı)** tekrar cazip hale geliyor:

### Önerilen model: Dikey bölünme

- **Kişi A:** `auth`, `firma`, `is-ilanlari`, `cookzone`, `harita` modüllerinin **hem backend (NestJS) hem frontend (React Native)** tarafını uçtan uca yazar
- **Kişi B:** `duyuru`, `banner`, `is-ortaklari`, `ikinci-el-pazar`, `acil-durum`, `paket-teslimi` modüllerinin **hem backend hem frontend** tarafını yazar

**İş yükü dengesi:** Kişi A'nın 4 modülü (`auth`, `firma`, `is-ilanlari`, `cookzone`) 3 katmanlı/karmaşık olduğu için, yanına basit bir modül (`harita`, 2 katman) eklendi. Kişi B'nin 6 modülünden 4'ü (`duyuru`, `banner`, `is-ortaklari`, `paket-teslimi`) basit/2 katmanlı, 2'si (`ikinci-el-pazar`, `acil-durum`) karmaşık — toplamda iki kişinin iş yükü kabaca dengeleniyor.

**Avantajı:** Bekleme neredeyse sıfır — kendi modülünü uçtan uca sen yazdığın için API şeklini "tahmin etmen" gerekmez, sözleşme senin kafanda zaten net. Ayrıca ikiniz de tam yığın (full-stack) deneyim kazanır — kariyer açısından, sadece "ben backend'ciyim" ya da "ben frontend'ciyim" demekten daha güçlü bir konum.

**Dikkat edilmesi gereken risk:** İki kişi birbirinin modülünden tamamen habersiz kalabilir. Bunu **modül-sonu kısa demo** ile (Bölüm 7'de her modül biter bitmez) telafi edin.

### Alternatif: Yatay bölünme + Contract-First (hâlâ geçerli bir seçenek)

Eğer ikinizden biri "ben backend'de kalayım, frontend'e hiç girmeyeyim" gibi net bir tercihe sahipse, yatay bölünme de burada çalışır — çünkü `packages/shared-types` (Bölüm 5) sayesinde sözleşme zaten kod seviyesinde paylaşılıyor, "backend bitmeden frontend bekler" sorunu büyük ölçüde azalıyor.

**Bu izlencenin geri kalanı dikey bölünme varsayımıyla yazıldı** — yatay tercih ederseniz Adım listesindeki "Kişi A / Kişi B" atamalarını "Backend / Frontend" olarak okuyabilirsiniz, yapı değişmez.

### Modül Geliştirme Protokolü — her modülde tekrarlanan, tek tip 4 alt-adım

**Bu protokol, her yeni modüle başlarken karşınıza çıkacak "diğer kişiye ne zaman haber vereyim / neyi bekleyeyim" sorusunun cevabıdır.** Bir kez okuyup içselleştirdikten sonra, Bölüm 7'deki her adım için tekrar sormanıza gerek kalmaz — aşağıdaki 4 alt-adımı uygulayın, yeter.

| Alt-adım | Ne yapılır | Süre | Diğer kişiyi bekler mi? |
|----------|------------|------|----------------------------|
| **a) Sözleşme** | Modülün `adapters/public/*.port.ts` arayüzü + `shared-types`'a ilgili DTO'lar yazılır. **İş mantığı henüz yok.** | 10-20 dk | Hayır — kimseyi beklemez |
| **b) Sözleşmeyi paylaş** | `a`'daki dosyalar küçük bir PR ile hemen `develop`'a merge edilir | Anında | Hayır — küçük, riski düşük, hızlı onaylanır |
| **c) Bağımlı olduğun modülün sözleşmesi henüz yoksa** | Kendi ilerlemen için geçici bir **sahte (fake) implementasyon** yaz (örn. `SahteFirmaSorgulamaAdapter` — her zaman `true` döner), kendi modülünü bununla geliştirmeye devam et | 5 dk | Hayır |
| **d) Gerçek implementasyon + entegrasyon** | `application`/`persistence` kodun bitince, sahteyi gerçek implementasyonla değiştir (`module.ts` içindeki `provide` satırı), PR aç, modül-sonu demo yap | Modülün geri kalanı kadar | Sadece kendi modülünüzün bitişini etkiler |

**Altın kural:** Bir modüle başlamadan önce ilk işiniz **her zaman (a)** olmalı — "önce iş mantığını yazayım, sözleşmeyi sona bırakayım" tam tersi bir sıra, diğer kişiyi gereksiz yere bekletir.

**Elif'in (veya herhangi bir ekip üyesinin) kendi başına bilmesi gereken şey:** Bölüm 7'deki kendi adımına bakar, o adımın "Girdi" sütununda yazan modül/arayüz henüz `develop`'ta yoksa, **kendisi (c) adımına göre bir sahte implementasyon yazıp beklemeden ilerler** — kimseye sormasına gerek yoktur, bu zaten protokolün bir parçası.

---

## 7. Adım Bazlı Plan

> **Tablodaki "Girdi" sütunu boşsa veya "yok" yazıyorsa, o adımı yapan kişi kimseyi beklemeden başlayabilir.** Girdi bir modül/arayüz ismi içeriyorsa ve o henüz `develop`'ta yoksa, Modül Geliştirme Protokolü'nün **(c)** alt-adımına göre sahte implementasyonla ilerleyin — sormaya gerek yok.

### FAZ 0 — Kurulum

| Adım | Kim | Girdi (ne bekler) | Yapılacaklar | Teslim/Çıktı |
|------|-----|---------------------|--------------|----------------|
| 1 | Birlikte | Yok | npm workspaces root; `packages/shared-types` (boş klasör); `packages/backend` — NestJS `modules/`+`shared/` klasörleri, ESLint boundaries kurulumu; `packages/mobile` — Expo init + Expo Router iskeleti; repo + `.gitignore` | Boş ama derlenen 3 paket, repo push'lanmış |
| 2 | Birlikte | Adım 1 | PostgreSQL Docker Compose; Prisma init; temel şema (`kullanici`, `firma`) | `docker compose up` çalışıyor, `prisma studio` tablo gösteriyor |
| 3 | Birlikte | Adım 2 | Swagger kurulumu; `/api/v1` versiyonlama (`app.enableVersioning`); `GlobalExceptionFilter`; health check; `shared/infrastructure/file-storage/file-storage.port.ts` + `local-file-storage.adapter.ts` iskeleti | Swagger `/api/v1/...` altında açık, `npm run lint` geçiyor, boş Expo uygulaması simülatörde açılıyor |

**FAZ 0 Teslim Kriteri:** Yukarıdaki 3 adımın hepsi ✓, iki kişi de kendi bilgisayarında `docker compose up` + `npm run dev` (backend) + `npx expo start` (mobile) komutlarını sorunsuz çalıştırabiliyor.

### FAZ 1 — Auth + Ana Sayfa + Firma + Profil

| Adım | Kim | Girdi (ne bekler) | Yapılacaklar (Protokol a→d) | Teslim/Çıktı (diğer kişi bunu kullanır) |
|------|-----|---------------------|-------------------------------|---------------------------------------------|
| 4 | Kişi A | Yok (FAZ 0 bitti) | `auth` modülü: **(a)** `shared-types/auth.types.ts` (RegisterRequest, LoginResponse) **(b)** hemen merge **(d)** backend JWT + `AuthService` (saf TS) + `AuthController`, Expo giriş/kayıt ekranları, Zustand `authStore` | `shared-types/auth.types.ts` + çalışan `/api/v1/auth/*` endpoint'leri — Kişi B'nin Profil ekranı bunu kullanır |
| 5 | Kişi B (Adım 4 ile paralel) | Yok | `banner`, `is-ortaklari`, `duyuru` modülleri uçtan uca (2 katman, basit CRUD) + Ana Sayfa ekranı | Çalışan Ana Sayfa — Adım 4'ü beklemez, kendi başına ilerler |
| 6 | Kişi A | Adım 4 bitti | `firma` modülü: **(a)** `firma-sorgulama.port.ts` + `shared-types/firma.types.ts`, hemen merge **(d)** `FirmaService` (BR-1), `FirmaController`, Firmalar ekranları | `firma/adapters/public/firma-sorgulama.port.ts` — Kişi B'nin Adım 8'de (`is-ilanlari`) ihtiyaç duyacağı arayüz burada hazır olur |
| 7 | Kişi B (Adım 6 ile paralel) | Adım 4'ün `authStore`'u | Profil ekranı; `app/(admin)/` route grubu iskeleti (rol kontrolü `authStore`'dan okunur) | Profil ekranı, admin route iskeleti |

**FAZ 1 Teslim Kriteri (Milestone 1):** Her iki kişi kendi modülünü diğerine Swagger + Expo üzerinden gösterir, mentor onayı alınır.

### FAZ 2 — İş İlanları + İkinci El Pazar + Harita

| Adım | Kim | Girdi (ne bekler) | Yapılacaklar | Teslim/Çıktı |
|------|-----|---------------------|--------------|----------------|
| 8 | Kişi A | `firma/adapters/public/firma-sorgulama.port.ts` (Adım 6'dan hazır) | `is-ilanlari` modülü: **(a)** arayüz+DTO **(d)** `IsIlaniService` (BR-2, `FirmaSorgulamaPort`'u gerçekten kullanır) + ekranlar | Çalışan İş İlanları modülü |
| 9 | Kişi B (paralel) | `shared/file-storage.port.ts` (FAZ 0'dan hazır) | `ikinci-el-pazar` modülü: **(a)** arayüz+DTO **(d)** backend (BR-3, BR-8, fotoğraf yükleme `FileStoragePort` üzerinden) + ekranlar (Expo `image-picker`) | Çalışan İkinci El Pazar modülü |
| 10 | Kişi A | Yok | `harita` modülü (2 katman) + ekran — iş yükü dengelemesi için A'ya atandı (bkz. Bölüm 6 modül dağılımı) | Çalışan Harita modülü |

**FAZ 2 Teslim Kriteri (Milestone 2):** Mentor demosu, `isterler.md` US-006/007/010 kabul kriterleri manuel test edilir.

### FAZ 3 — Cookzone + Acil Durum + Paket Teslimi

| Adım | Kim | Girdi (ne bekler) | Yapılacaklar | Teslim/Çıktı |
|------|-----|---------------------|--------------|----------------|
| 11 | Kişi A | Yok | `cookzone` modülü — durum makinesi (`SiparisDurumYoneticisi`) + menü/sipariş ekranları | Çalışan Cookzone modülü |
| 12 | Kişi B (paralel) | Yok | `acil-durum` modülü — BR-5 + bildirim ekranı | Çalışan Acil Durum modülü |
| 13 | Kişi B | Yok | `paket-teslimi` modülü (2 katman) — iş yükü dengelemesi için B'ye atandı | Çalışan Paket Teslimi modülü |

**FAZ 3 Teslim Kriteri (Milestone 3):** Mentor demosu, US-008/009 kabul kriterleri manuel test edilir.

### FAZ 4 — Cilalama, Deploy

| Adım | Kim | Girdi (ne bekler) | Yapılacaklar | Teslim/Çıktı |
|------|-----|---------------------|--------------|----------------|
| 14 | Birlikte | Tüm modüller (FAZ 1-3) bitmiş | `react-native-web` entegrasyonu; harita/kamera gibi native modüllerin web karşılıkları (`Platform.OS === 'web'` kontrolü); CORS; responsive kontrol | Aynı kod tabanından çalışan web sürümü |
| 15 | Birlikte | Adım 14 | Docker prod build (multi-stage); GitHub Actions CI (lint + test + build, `shared-types` senkron kontrolü) | CI yeşil, prod imajı hazır |
| 16 | Birlikte | Adım 15 | `isterler.md`'deki tüm User Story kabul kriterleri tek tek manuel test edilir | Pass/fail listesi, bug fix PR'ları |
| 17 | Birlikte | Adım 16 | Canlıya alma (`docker compose -f docker-compose.prod.yml up -d`); demo; retrospektif | **Proje teslimi** |

---

## 8. Değerlendirme Kriterleri

| Ağırlık | Kriter |
|---------|--------|
| %25 | Modül sınırı disiplini — `eslint-plugin-boundaries` hatasız |
| %20 | Katman derinliği kararının gerekçeli olması |
| %20 | İş kuralları — `application`/`domain`'de, framework'süz test edilebilir |
| %15 | React Native UX — Nielsen ilkeleri, web/native davranış farklarının doğru yönetimi |
| %10 | API tasarımı — versiyonlama, tutarlı hata formatı |
| %10 | Git disiplini, contract-first işbirliği |

## 9. Kontrol Listesi

- [ ] `domain` ve `application` katmanlarında Nest decorator'ı yok (saf TS)
- [ ] `eslint-plugin-boundaries` CI'da çalışıyor, ihlal yok
- [ ] Basit modüllerde (`duyuru`, `harita`, `paket-teslimi`) gereksiz `application` katmanı yok
- [ ] Modüller arası erişim sadece `adapters/public/` üzerinden
- [ ] Hata formatı tüm API'de tutarlı
- [ ] Her React Native ekranı Nielsen checklist'inden geçmiş
- [ ] `packages/shared-types` her iki tarafta da güncel, tip uyuşmazlığı yok
- [ ] Native modül gerektiren ekranlar (harita, kamera) web'de test edilmiş veya bilinçli olarak kısıtlanmış
- [ ] Tüm endpoint'ler `/api/v1/...` altında, versiyonlama `app.module.ts`'de tanımlı
- [ ] Fotoğraf yükleme `FileStoragePort` üzerinden yapılıyor, ilgili modül doğrudan disk/S3 API'sini bilmiyor
- [ ] Admin ekranları (`app/(admin)/`) sadece `rol=admin` girişte erişilebilir, ayrı bir deploy hattı yok
- [ ] CI yeşil, `main` deploy edilebilir

---

*İlgili dokümanlar: `isterler.md`, `teknikPlan.md` (veri modeli referansı)*
*Son güncelleme: 21.07.2026*
