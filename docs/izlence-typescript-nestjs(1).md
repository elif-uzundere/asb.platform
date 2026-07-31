# İzlence — TypeScript + NestJS + Flutter + PostgreSQL
## ASB Platform — Modül-Önce Katmanlı Mimari, 2 Kişilik Paralel Çalışma Planı

> **28.07.2026 güncellemesi:** Mentör talimatıyla frontend **React Native/Expo'dan Flutter'a** geçildi (backend NestJS/TypeScript değişmedi) ve bu doküman Flutter karşılıklarıyla **elden geçirildi** — Bölüm 2 (klasör ağacı), Bölüm 5 (frontend katmanlama + state), Bölüm 6 (ekip gerekçesi) ve Bölüm 7'deki adım tabloları güncel. Eski Expo kodu (`packages/mobile`) 28.07.2026'da **silindi**; geçiş karşılıkları ve tasarım sabitleri **Ek A**'da arşivli.
>
> **Yeni modül açarken:** klasör/dosya tarifi, kod örnekleri ve kontrol listesi için `docs/YENI-MODUL-REHBERI.md`.
>
> **Kaybolan güvence:** "Aynı dil (TypeScript) → `shared-types` ile derleme zamanı tip güvenliği" argümanı Dart ile geçerli değil. Yerine elle tutulan Dart aynası + testler kondu (Bölüm 5).

| Alan | Değer |
|------|-------|
| **Backend** | Node.js 20 LTS + NestJS + TypeScript |
| **Frontend** | ~~React Native (Expo) + TypeScript~~ → **Flutter (Dart)**, 27.07.2026'da mentör talimatıyla değişti. Riverpod, go_router, dio, flutter_secure_storage |
| **State management** | ~~Zustand~~ → **Riverpod** (Flutter geçişiyle). Form akışları ortak `FormNotifier` tabanından türer |
| **HTTP client** | ~~Axios~~ → **dio** (interceptor ile token yönetimi) |
| **Routing** | **go_router** — `ShellRoute` ile bottom tab, `redirect` ile rota koruması |
| **Token saklama** | **flutter_secure_storage** (web'de şifreli localStorage) |
| **Veritabanı** | PostgreSQL 16 |
| **ORM** | Prisma |
| **Dosya/fotoğraf depolama** | Yerel disk (Docker volume) — `FileStoragePort` arkasında soyutlanmış, ileride S3/MinIO'ya geçiş kod değişikliği gerektirmez |
| **Repo yapısı** | **Monorepo** (npm workspaces) — `packages/shared-types` tek kaynak; Dart tarafında **elle tutulan ayna** (`packages/app/lib/core/models/`), çünkü Dart TS paketini import edemiyor |
| **Admin paneli** | ⚠️ **KARAR BEKLİYOR** — rol bazlı rota mı, ayrı AdminJS mi netleşmedi. Flutter'da admin rotası bilerek kurulmadı, kod yazmadan önce sor |
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
| `palet-tesisi`, `harita` | Basit durum takibi / coğrafi sorgu | **2 katman** |

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

Repo yapısı kararı: **monorepo**. Özgün gerekçe — `packages/shared-types` sayesinde backend'deki bir DTO değiştiğinde frontend derleme zamanında hata alır, ayrı repo'da bu tip paylaşımı için ekstra bir npm publish süreci gerekirdi.

> **Flutter geçişinden sonra:** Bu gerekçenin "derleme zamanında hata alır" kısmı Dart tarafı için **artık geçerli değil** (Dart, TS paketini import edemiyor). Monorepo yine de korunuyor: tek repo/tek PR ile sözleşme + backend + frontend aynı anda değişebiliyor, CI tek pipeline. Tip uyumu artık derleyiciyle değil **disiplinle** sağlanıyor — `shared-types` değişirse Dart aynası aynı PR'da güncellenir (Bölüm 5).

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
│   │   │   │   ├── palet-tesisi/            # 2 katman — application yok
│   │   │   │   │   ├── domain/
│   │   │   │   │   ├── adapters/{web,persistence}/
│   │   │   │   │   └── palet-tesisi.module.ts
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
│   ├── app/                                  # ★ asb_app — Flutter (AKTİF frontend)
│   │   ├── lib/
│   │   │   ├── core/                         # Tüm feature'ların paylaştığı altyapı
│   │   │   │   ├── models/                   # shared-types'ın EL İLE tutulan Dart aynası
│   │   │   │   ├── network/
│   │   │   │   │   ├── api_client.dart       # dio örneği + token interceptor
│   │   │   │   │   ├── api_istegi.dart       # ★ Zarf çözme + hata çevirme (tek yer)
│   │   │   │   │   └── api_hata.dart
│   │   │   │   ├── storage/                  # flutter_secure_storage sarmalayıcı
│   │   │   │   ├── durum/islem_durumu.dart   # ★ FormNotifier — yükleniyor/hata/çift tıklama
│   │   │   │   ├── router/                   # go_router + bottom tab kabuğu
│   │   │   │   ├── theme/renkler.dart
│   │   │   │   └── widgets/                  # GirdiKutusu, BirincilButon, dialog yardımcıları
│   │   │   ├── features/
│   │   │   │   ├── auth/                     # ← 3 katmanın referans örneği
│   │   │   │   │   ├── data/                 # dio çağrıları
│   │   │   │   │   ├── domain/               # saf kurallar (Flutter import'u YOK)
│   │   │   │   │   └── presentation/
│   │   │   │   │       ├── durum/            # Riverpod notifier'lar
│   │   │   │   │       ├── ekranlar/         # SADECE görünüm
│   │   │   │   │       └── widgets/
│   │   │   │   ├── ana_sayfa/                # banner carousel — ilk uçtan uca entegrasyon
│   │   │   │   ├── firmalar/                 # şimdilik placeholder
│   │   │   │   ├── harita/
│   │   │   │   └── duyurular/
│   │   │   └── main.dart
│   │   ├── test/                             # lib/ yapısını birebir yansıtır
│   │   │   ├── core/
│   │   │   └── features/
│   │   ├── assets/images/
│   │   └── pubspec.yaml                      # npm'in Flutter karşılığı
│   │
│   └── mobile/                               # @asb/mobile — ESKİ Expo kodu
│       │                                     # ÇALIŞTIRILMIYOR; sadece iş kuralı/UX referansı
│       ├── app/                              # Expo Router sayfaları
│       ├── src/{core,features}/
│       └── package.json
│
├── docker-compose.yml
├── docker-compose.prod.yml
└── README.md
```

### Admin paneli — **karar bekliyor, kod yazma**

Eski plan: `Kullanici.rol === 'admin'` ile giren kullanıcı aynı uygulamada `(admin)` route grubunu görür. Flutter'daki karşılığı go_router'da rol bazlı `redirect` olurdu. **Ancak bu karar netleşmedi** — AdminJS'e (ayrı, hazır admin paneli) geçiş de konuşuluyor. Bu yüzden Flutter tarafında admin rotası **bilerek kurulmadı**. Karar verilmeden bu konuda kod yazılmayacak (bkz. `CLAUDE.md` → Henüz Kesinleşmemiş Kararlar).

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
- Response zarfı, hata formatı, versiyonlama `shared/web/` altında tek yerde — her modül tekrar üretmez
- Prisma şeması tek dosyada (`schema.prisma`), her modül kendi tablosunu tanımlar ama migration tek pipeline'dan geçer

---

## 4. Veritabanı ve Migration

Şema `teknikPlan.md` Bölüm 4 ile birebir aynı. Migration: **Prisma Migrate** (`npx prisma migrate dev`), dosyalar `prisma/migrations/` altında otomatik üretilir.

---

## 5. Flutter Tarafı — Katmanlama ve Nielsen'in 10 Kullanılabilirlik İlkesi

> **27.07.2026 notu:** Bu bölüm önce React Native/Expo'ya göre yazılmıştı. Mentör talimatıyla frontend **Flutter**'a geçti; aşağısı Flutter karşılıklarıyla güncellendi. Eski Expo kodu silindi; karşılıklar **Ek A**'da.

| # | İlke | ASB Platform karşılığı (Flutter) |
|---|------|----------------------------|
| 1 | Sistem durumu görünürlüğü | `CircularProgressIndicator`, `IslemSuruyor` durumunda buton metni ("Giriş yapılıyor...") |
| 2 | Gerçek dünya eşleşmesi | Tanıdık terimler ("Onayla" vb.) |
| 3 | Kullanıcı kontrolü | go_router ile geri dönülebilir akış, onay dialog'ları |
| 4 | Tutarlılık | Sabit `BottomNavigationBar` (ShellRoute), ortak `GirdiKutusu`/`BirincilButon` |
| 5 | Hata önleme | `TextInputType` ile klavye kısıtı, **çift tıklama koruması** (`FormNotifier`) |
| 6 | Tanıma > hatırlama | Dropdown/Picker seçimler |
| 7 | Esneklik | Acil Durum tek dokunuşla |
| 8 | Minimalizm | Mockup'taki 8 modülün dışına çıkılmaz |
| 9 | Hata teşhisi | Backend'in Türkçe `error.message`'ı dialog'da **olduğu gibi** gösterilir |
| 10 | Yardım | Tooltip, SSS, form altı ipuçları ("En az 8 karakter, 1 rakam") |

### Katmanlama — backend felsefesinin frontend karşılığı

Detaylı klasör ağacı Bölüm 2'de (`packages/app/`). Uygulama tarifi ve kontrol listesi → **`docs/YENI-MODUL-REHBERI.md`**.

Her feature üç katmana ayrılır ve backend'deki mantıkla birebir eşleşir:

| Backend | Flutter | Sorumluluk |
|---|---|---|
| `adapters/web` (Controller) | `presentation/ekranlar` (Widget) | Dış dünya — sadece görünüm |
| `application` (Service) | `presentation/durum` (Riverpod Notifier) | Akış/orkestrasyon |
| `domain` | `domain` | Saf kurallar — framework import'u YOK |
| `adapters/persistence` | `data` | Altyapı (Prisma ↔ dio) |

**Kritik kural:** Widget içinde API çağrısı, `try/catch`, elle `bool _yukleniyor`, `.trim()` veya `if/else` iş kuralı **olmaz**. Bunlar `FormNotifier` / `domain` / `data` katmanına aittir (`CLAUDE.md` md. 8-13).

### State management — Riverpod

- **Veri okuma** (liste/detay): `FutureProvider` → ekranda `.when(loading:, error:, data:)`
- **Form gönderme**: `core/durum/islem_durumu.dart` içindeki `FormNotifier`'dan türet — yükleniyor durumu, `ApiHata` yakalama ve çift tıklama koruması hazır gelir
- **Oturum**: `authProvider` (`StateNotifier`) + `flutter_secure_storage` ile kalıcılık

### Ortak tip paylaşımı — dil birliği kaybolunca ne değişti

TypeScript+React Native'de `packages/shared-types` hem backend hem frontend tarafından import edilebiliyordu ve "backend'de alan adı değişti, frontend unuttu" hatası **derleme zamanında** yakalanıyordu. **Flutter'a geçince bu güvence kayboldu** — Dart, TS paketini import edemiyor.

Yerine konan çözüm: `packages/app/lib/core/models/` altında **elle tutulan Dart aynası** + her dosyanın başında kaynak TS dosyası + JSON çözümleme testleri. Bu, derleyici güvencesinin yerini tutmaz; bu yüzden **kural**: `shared-types`'ta bir tip değişirse Dart aynası AYNI PR'da güncellenir. Modül sayısı artınca Swagger/OpenAPI'den Dart model üretimine geçiş konuşulacak (bkz. `CLAUDE.md` → Alınan Kararlar).

### Web desteği notu

Şu anki geliştirme hedefi **Chrome (web)**: `flutter run -d chrome`. Flutter web **hash routing** kullanıyor (`/#/giris`), bu yüzden e-posta/derin link üretirken adres formatına dikkat — backend'in `SIFIRLAMA_LINK_TABANI` değişkeni buna göre ayarlanmalı. Harita/kamera gibi native yetenekler Adım 14'te (Web uyarlaması) ayrıca ele alınacak.

---

## 6. İki Kişilik Ekip — Neden burada tavsiye değişiyor

Java+Flutter'da "yatay bölünme" (biri hep backend, biri hep frontend) önermiştik çünkü Java ve Dart birbirinden çok uzak iki dünyaydı. TypeScript + React Native'de bu engel ortadan kalkmıştı (aynı dil, aynı ekosistem) ve dikey bölünme seçilmişti.

> **27.07.2026 — bu gerekçe kısmen geçersizleşti:** Flutter'a geçişle backend (TypeScript) ve frontend (Dart) tekrar **iki ayrı dil** oldu. Dikey bölünme yine de korunuyor, çünkü asıl kazanç dil birliği değil **bekleme süresinin sıfır olması**: kendi modülünün sözleşmesini kendin yazdığın için kimseyi beklemiyorsun. Ama iki gerçek maliyeti kabul ediyoruz:
> 1. Herkes iki dil birden öğrenecek (Dart tarafı için `docs/YENI-MODUL-REHBERI.md` şablon sunuyor — sıfırdan tasarlamak gerekmiyor).
> 2. Derleme zamanı tip güvenliği kayboldu; `shared-types` ↔ Dart aynası **elle** senkron tutuluyor (bkz. Bölüm 5).

### Önerilen model: Dikey bölünme

- **Kişi A:** `auth`, `firma`, `is-ilanlari`, `cookzone`, `harita` modüllerinin **hem backend (NestJS) hem frontend (Flutter)** tarafını uçtan uca yazar
- **Kişi B:** `duyuru`, `banner`, `is-ortaklari`, `ikinci-el-pazar`, `acil-durum`, `palet-tesisi` modüllerinin **hem backend hem frontend** tarafını yazar

**İş yükü dengesi:** Kişi A'nın 4 modülü (`auth`, `firma`, `is-ilanlari`, `cookzone`) 3 katmanlı/karmaşık olduğu için, yanına basit bir modül (`harita`, 2 katman) eklendi. Kişi B'nin 6 modülünden 4'ü (`duyuru`, `banner`, `is-ortaklari`, `palet-tesisi`) basit/2 katmanlı, 2'si (`ikinci-el-pazar`, `acil-durum`) karmaşık — toplamda iki kişinin iş yükü kabaca dengeleniyor.

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
| 1 | Birlikte | Yok | npm workspaces root; `packages/shared-types` (boş klasör); `packages/backend` — NestJS `modules/`+`shared/` klasörleri, ESLint boundaries kurulumu; `packages/mobile` — Expo init + Expo Router iskeleti *(27.07.2026'da terk edildi; yerine `packages/app` — `flutter create` + go_router iskeleti)*; repo + `.gitignore` | Boş ama derlenen 3 paket, repo push'lanmış |
| 2 | Birlikte | Adım 1 | PostgreSQL Docker Compose; Prisma init; temel şema (`kullanici`, `firma`) | `docker compose up` çalışıyor, `prisma studio` tablo gösteriyor |
| 3 | Birlikte | Adım 2 | Swagger kurulumu; `/api/v1` versiyonlama (`app.enableVersioning`); `GlobalExceptionFilter`; health check; `shared/infrastructure/file-storage/file-storage.port.ts` + `local-file-storage.adapter.ts` iskeleti | Swagger `/api/v1/...` altında açık, `npm run lint` geçiyor, boş Flutter uygulaması `flutter run -d chrome` ile açılıyor |

**FAZ 0 Teslim Kriteri:** Yukarıdaki 3 adımın hepsi ✓, iki kişi de kendi bilgisayarında `docker compose up` + `npm run dev:backend` + `flutter run -d chrome` (packages/app içinden) komutlarını sorunsuz çalıştırabiliyor.

### FAZ 1 — Auth + Ana Sayfa + Firma + Profil

| Adım | Kim | Girdi (ne bekler) | Yapılacaklar (Protokol a→d) | Teslim/Çıktı (diğer kişi bunu kullanır) |
|------|-----|---------------------|-------------------------------|---------------------------------------------|
| 4 | Kişi A | Yok (FAZ 0 bitti) | `auth` modülü: **(a)** `shared-types/auth.types.ts` (RegisterRequest, LoginResponse) **(b)** hemen merge **(d)** backend JWT + `AuthService` (saf TS) + `AuthController`, Flutter giriş/kayıt/şifre-sıfırlama ekranları, Riverpod `authProvider` + `flutter_secure_storage` | `shared-types/auth.types.ts` + çalışan `/api/v1/auth/*` endpoint'leri — Kişi B'nin Profil ekranı bunu kullanır |
| 5 | Kişi B (Adım 4 ile paralel) | Yok | `banner`, `is-ortaklari`, `duyuru` modülleri uçtan uca (2 katman, basit CRUD) + Ana Sayfa ekranı | Çalışan Ana Sayfa — Adım 4'ü beklemez, kendi başına ilerler |
| 6 | Kişi A | Adım 4 bitti | `firma` modülü: **(a)** `firma-sorgulama.port.ts` + `shared-types/firma.types.ts`, hemen merge **(d)** `FirmaService` (BR-1), `FirmaController`, Firmalar ekranları | `firma/adapters/public/firma-sorgulama.port.ts` — Kişi B'nin Adım 8'de (`is-ilanlari`) ihtiyaç duyacağı arayüz burada hazır olur |
| 7 | Kişi B (Adım 6 ile paralel) | Adım 4'ün `authProvider`'ı | Profil ekranı. ⚠️ Admin route grubu **kaldırıldı** — AdminJS kararı netleşmedi, kod yazmadan önce sor | Profil ekranı |

**FAZ 1 Teslim Kriteri (Milestone 1):** Her iki kişi kendi modülünü diğerine Swagger + `flutter run -d chrome` üzerinden gösterir, mentor onayı alınır.

### FAZ 2 — İş İlanları + İkinci El Pazar + Harita

| Adım | Kim | Girdi (ne bekler) | Yapılacaklar | Teslim/Çıktı |
|------|-----|---------------------|--------------|----------------|
| 8 | Kişi A | `firma/adapters/public/firma-sorgulama.port.ts` (Adım 6'dan hazır) | `is-ilanlari` modülü: **(a)** arayüz+DTO **(d)** `IsIlaniService` (BR-2, `FirmaSorgulamaPort`'u gerçekten kullanır) + ekranlar | Çalışan İş İlanları modülü |
| 9 | Kişi B (paralel) | `shared/file-storage.port.ts` (FAZ 0'dan hazır) | `ikinci-el-pazar` modülü: **(a)** arayüz+DTO **(d)** backend (BR-3, BR-8, fotoğraf yükleme `FileStoragePort` üzerinden) + ekranlar (Expo `image-picker`) | Çalışan İkinci El Pazar modülü |
| 10 | Kişi A | Yok | `harita` modülü (2 katman) + ekran — iş yükü dengelemesi için A'ya atandı (bkz. Bölüm 6 modül dağılımı) | Çalışan Harita modülü |

**FAZ 2 Teslim Kriteri (Milestone 2):** Mentor demosu, `isterler.md` US-006/007/010 kabul kriterleri manuel test edilir.

### FAZ 3 — Cookzone + Acil Durum + Palet Tesisi

| Adım | Kim | Girdi (ne bekler) | Yapılacaklar | Teslim/Çıktı |
|------|-----|---------------------|--------------|----------------|
| 11 | Kişi A | Yok | `cookzone` modülü — durum makinesi (`SiparisDurumYoneticisi`) + menü/sipariş ekranları | Çalışan Cookzone modülü |
| 12 | Kişi B (paralel) | Yok | `acil-durum` modülü — BR-5 + bildirim ekranı | Çalışan Acil Durum modülü |
| 13 | Kişi B | Yok | `palet-tesisi` modülü (2 katman) — iş yükü dengelemesi için B'ye atandı | Çalışan Palet Tesisi modülü |

**FAZ 3 Teslim Kriteri (Milestone 3):** Mentor demosu, US-008/009 kabul kriterleri manuel test edilir.

### FAZ 4 — Cilalama, Deploy

| Adım | Kim | Girdi (ne bekler) | Yapılacaklar | Teslim/Çıktı |
|------|-----|---------------------|--------------|----------------|
| 14 | Birlikte | Tüm modüller (FAZ 1-3) bitmiş | Flutter Web cilası; harita/kamera gibi native yeteneklerin web karşılıkları (`kIsWeb` kontrolü); CORS'un gerçek domain listesiyle sınırlanması; responsive kontrol | Aynı kod tabanından çalışan web sürümü |
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
| %15 | Flutter UX — Nielsen ilkeleri, katman disiplini (widget'ta iş mantığı yok), web/native davranış farkları |
| %10 | API tasarımı — versiyonlama, tutarlı hata formatı |
| %10 | Git disiplini, contract-first işbirliği |

## 9. Kontrol Listesi

- [ ] `domain` ve `application` katmanlarında Nest decorator'ı yok (saf TS)
- [ ] `eslint-plugin-boundaries` CI'da çalışıyor, ihlal yok
- [ ] Basit modüllerde (`duyuru`, `harita`, `palet-tesisi`) gereksiz `application` katmanı yok
- [ ] Modüller arası erişim sadece `adapters/public/` üzerinden
- [ ] Hata formatı tüm API'de tutarlı
- [ ] Her Flutter ekranı Nielsen checklist'inden geçmiş
- [ ] Flutter tarafında widget içinde API çağrısı / iş kuralı / try-catch yok (bkz. `YENI-MODUL-REHBERI.md`)
- [ ] `packages/shared-types` ve Dart aynası (`packages/app/lib/core/models/`) senkron
- [ ] Gövde alan her DTO'da class-validator kuralı + Türkçe `message` var
- [ ] Native modül gerektiren ekranlar (harita, kamera) web'de test edilmiş veya bilinçli olarak kısıtlanmış
- [ ] Tüm endpoint'ler `/api/v1/...` altında, versiyonlama `app.module.ts`'de tanımlı
- [ ] Fotoğraf yükleme `FileStoragePort` üzerinden yapılıyor, ilgili modül doğrudan disk/S3 API'sini bilmiyor
- [ ] Admin ekranları sadece `rol=admin` girişte erişilebilir, ayrı bir deploy hattı yok *(⚠️ admin kararı henüz netleşmedi — bkz. Bölüm 2)*
- [ ] CI yeşil, `main` deploy edilebilir

---

## Ek A — Expo → Flutter Geçiş Arşivi

> **28.07.2026:** `packages/mobile` (eski Expo/React Native kodu) **repodan silindi.** Gerekçe: kök `package.json`'daki `workspaces: ["packages/*"]` glob'u onu da kapsadığı için her `npm install`/`npm ci` yüzlerce MB Expo + React Native bağımlılığı indiriyordu — hâlbuki kod artık ne çalıştırılıyor ne derleniyor ne de test ediliyordu. Ölü ağırlık taşımamak (clean code) için kaldırıldı.
>
> **Silmeden önce kontrol edildi:** Portlanmamış tek ekranlar (`firmalar`, `harita`, `duyurular`, `(admin)`) zaten ortada tek satır `<Text>` gösteren boş yer tutuculardı — Flutter tarafında birebir karşılıkları var. Yani kaybolan iş kuralı/UX bilgisi **yok**. Yine de aşağıdaki tablo ve sabitler arşiv olarak burada tutuluyor.
>
> **Koda erişmek gerekirse:** git geçmişinde duruyor.
> `git log --all --oneline -- packages/mobile` ile silinmeden önceki son commit'i bul,
> `git show <commit>:packages/mobile/app/giris.tsx` ile tek dosyayı oku,
> `git checkout <commit> -- packages/mobile` ile tamamını geri getir.

### A.1 Dosya karşılıkları (ne, neye dönüştü)

| Expo (`packages/mobile`) | Flutter (`packages/app`) | Not |
|---|---|---|
| `app/_layout.tsx` + `app/index.tsx` | `lib/core/router/yonlendirici.dart` | Expo Router → go_router; "giriş yapılmamışsa /giris" mantığı `redirect` callback'ine taşındı |
| `app/(tabs)/_layout.tsx` | `lib/core/router/sekme_kabugu.dart` | `<Tabs>` → `ShellRoute` + `BottomNavigationBar` |
| `app/giris.tsx` | `features/auth/presentation/ekranlar/giris_ekrani.dart` | |
| `app/kayit.tsx` | `.../kayit_ekrani.dart` | Kayıt sonrası otomatik giriş **yok** (US-001 sapması) |
| `app/sifremi-unuttum.tsx` | `.../sifremi_unuttum_ekrani.dart` | |
| `app/sifre-sifirla.tsx` | `.../sifre_sifirla_ekrani.dart` | Ham token alanı artık kullanıcıya **gösterilmiyor** |
| `app/(tabs)/index.tsx` | `features/ana_sayfa/presentation/ekranlar/ana_sayfa_ekrani.dart` | |
| `app/(tabs)/profil.tsx` | `features/auth/presentation/ekranlar/profil_ekrani.dart` | |
| `app/(tabs)/{firmalar,harita,duyurular}.tsx` | `features/{firmalar,harita,duyurular}/presentation/ekranlar/` | Üçü de boş yer tutucuydu, öyle taşındı |
| `app/(admin)/` | **karşılığı kurulmadı** | AdminJS kararı netleşmedi (Bölüm 2) |
| `src/core/theme/renkler.ts` | `lib/core/theme/renkler.dart` | Palet birebir (A.2) |
| `src/core/api/client.ts` (axios) | `lib/core/network/api_client.dart` (dio) | Token interceptor aynı davranış |
| `src/core/stores/auth.store.ts` (Zustand + persist) | `lib/features/auth/presentation/durum/auth_durumu.dart` + `lib/core/storage/auth_depo.dart` | `expo-secure-store` → `flutter_secure_storage`; depo anahtarı aynı: `asb-auth` |
| `src/features/auth/auth.api.ts` | `features/auth/data/auth_api.dart` | |
| `src/features/ana-sayfa/components/banner.tsx` | `features/ana_sayfa/presentation/widgets/banner_carousel.dart` | Mekanik birebir (A.3), **ama artık gerçekten `GET /banners`'a bağlı** |
| `assets/images/giris-hero.jpeg` | `packages/app/assets/images/giris-hero.jpeg` | Birebir kopyalandı (aynı dosya) |

### A.2 Renk paleti (kaynağı Expo koduydu, Dart'a taşındı)

| İsim | Değer |
|---|---|
| `lacivert` | `#042C53` |
| `mavi` | `#1E7FD8` |
| `altin` | `#F5B400` |
| `beyaz` | `#FFFFFF` |
| `metinIkincil` | `#6B7280` |
| `kenarlik` | `#E5E7EB` |

### A.3 Banner carousel sabitleri (mockup'tan gelen ölçüler)

- Genişlik: `min(ekran genişliği - 32, 700)`, yükseklik `100`, köşe yarıçapı `16`
- Otomatik kaydırma: **2 saniyede bir**, sona gelince başa döner
- Nokta göstergesi: pasif `8×8` `#CCCCCC`; aktif genişlik `20`, renk `#0A4D8C`
- Dış boşluk: üst `8`, alt `20`

### A.4 Form ölçüleri (giriş/kayıt ekranları)

- Girdi kutusu yüksekliği `46`, köşe `10`, kenarlık `#E5E7EB`, yatay iç boşluk `14`
- Birincil buton yüksekliği `48`, köşe `10`, arka plan `lacivert`
- Kart üst köşeleri `28`, hero görselin üstüne `-28` (giriş) / `-24` (kayıt) taşar
- Hero görsel yüksekliği: giriş `380`, kayıt `320`
- Web'de içerik genişliği `max 430` ile sınırlanır
- Sosyal giriş düğmeleri: `44×44` daire, kenarlık `#E5E7EB` — OAuth gelene kadar "Yakında" mesajı

---

*İlgili dokümanlar: `isterler.md`, `teknikPlan.md` (veri modeli referansı), `YENI-MODUL-REHBERI.md` (yeni modül açma tarifi)*
*Son güncelleme: 28.07.2026*
