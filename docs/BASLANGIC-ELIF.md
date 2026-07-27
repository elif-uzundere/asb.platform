# Elif için Başlangıç Rehberi — ASB Platform

> Bu doküman `isterler.md`, `teknikPlan.md` ve `izlence-typescript-nestjs(1).md` dosyalarının **özeti + şu anki durum + senin ilk adımların** için hazırlandı. Detaya indiğinde her zaman o üç dosyaya (ve `CLAUDE.md`'deki sabit mimari kurallarına) dön — burada sadece yol haritasını görüyorsun.

---

## 1. Ekip ve Roller

| Kişi | Rol | Sorumlu olduğu modüller (hem backend hem mobile, uçtan uca) |
|------|-----|----------------------------------------------------------|
| **Berzan (Kişi A)** | Backend + Mobile | `auth`, `firma`, `is-ilanlari`, `cookzone`, `harita` |
| **Elif (Kişi B)** | Backend + Mobile | `duyuru`, `banner`, `is-ortaklari`, `ikinci-el-pazar`, `acil-durum`, `paket-teslimi` |

**Dikey bölünme** kullanılıyor — yani kendi modülünün hem NestJS (backend) hem Expo/React Native (mobile) tarafını sen yazıyorsun. API şeklini "tahmin etmen" gerekmiyor çünkü sözleşmeyi (DTO/port) de sen yazacaksın (aşağıda Bölüm 5).

---

## 2. Şu Anki Durum (FAZ 0 — tamamlandı ✓)

Aşağıdakiler zaten kurulu ve `develop` branch'inde:

- ✅ Monorepo iskeleti (npm workspaces): `packages/shared-types`, `packages/backend`, `packages/mobile`
- ✅ Backend: NestJS proje yapısı, 11 modülün klasör iskeleti (`domain`/`application`/`adapters` — karmaşıklığa göre 2 veya 3 katman), `eslint-plugin-boundaries` kuralları
- ✅ **Veritabanı şeması — 15 tablonun tamamı** `packages/backend/prisma/schema.prisma` içinde tanımlı **ve** `prisma migrate dev` ile gerçek PostgreSQL'de (boş tablolar olarak) oluşturulmuş durumda
- ✅ Swagger (`/api/v1/docs`), `/api/v1` versiyonlama, `GlobalExceptionFilter`, health check (`/api/v1/health`), `FileStoragePort` + yerel disk adapter'ı
- ✅ Mobile: Expo Router iskeleti — `(tabs)` grubu (Ana Sayfa, Firmalar, Harita, Duyurular, Profil) + `(admin)` grubu (rol kontrolü henüz bağlanmadı)
- ✅ `docker-compose.yml` (PostgreSQL 16, **port 5434** — bilgisayarında yerel bir Postgres kuruluysa 5432 ile çakışmasın diye böyle ayarlandı)
- ✅ GitHub Actions CI (`lint` + `build` + `test`)

**Henüz yapılmadı (bilerek boş bırakıldı):** Hiçbir modülün iş mantığı, hiçbir gerçek endpoint, hiçbir gerçek ekran içeriği. Sadece "derlenen ama boş" bir iskelet var — senin ve Berzan'ın üstüne inşa etmesi için.

---

## 3. Bilgisayarına Kurman Gerekenler

| Araç | Neden | Not |
|------|-------|-----|
| **Node.js 20 LTS** | Backend + mobile + workspaces için | [nodejs.org](https://nodejs.org)'dan LTS sürüm |
| **Git** | Versiyon kontrol | — |
| **Docker Desktop** | PostgreSQL'i container'da çalıştırmak için | Windows'ta WSL2 backend önerilir |
| **VS Code** | Ortak editör | Eklentiler: **ESLint**, **Prisma** (syntax highlight), **Expo Tools** |
| **Expo Go** (telefonuna) | Mobile uygulamayı gerçek cihazda test etmek için | App Store / Play Store |
| *(opsiyonel)* Android Studio veya Xcode | Emülatör/simülatör ile test | Expo Go yeterli değilse |

**Not:** Proje bağımlılıklarının (NestJS, Prisma, Swagger, Zustand, Axios, Expo Router vb.) hiçbirini tek tek kurmana gerek yok — hepsi `package.json` dosyalarında tanımlı, tek komutla (`npm install`) hepsi gelir.

---

## 4. Projeyi Kendi Bilgisayarında Ayağa Kaldırma

```powershell
git clone https://github.com/BerzanTemel/asb-platform.git
cd asb-platform
git checkout develop

npm install

Copy-Item packages\backend\.env.example packages\backend\.env

docker compose up -d
docker ps   # postgres:16 imajlı, 5434 portlu container'ı görmelisin

npm run prisma:migrate --workspace=@asb/backend
# Bu komut senin makinende yeni bir migration İSTEMEZ (şema zaten var),
# sadece mevcut migration'ı senin DB'ne uygular. Migration adı sorarsa
# ve schema'da değişiklik yoksa direkt uygulanır.

npm run dev:backend   # http://localhost:3000/api/v1/docs açılmalı
npm run dev:mobile    # Expo başlar, QR kodu Expo Go ile okut
```

Bir yerde takılırsan komutu ve tam hata mesajını Berzan'a ilet — sırasıyla ilerleyelim, tahmin yürütmeyelim.

---

## 5. Referans Dokümanlar — Hangi Soru İçin Hangisine Bakılır

| Sorun/İhtiyaç | Doküman | Bölüm |
|----------------|---------|-------|
| "Bu modül ne iş yapmalı, kabul kriterleri ne?" | `isterler.md` | Bölüm 5 — User Story'ler (Epic 4 = Duyuru, Epic 2 = Ana Sayfa/Banner) |
| "Hangi alanlar var, tipleri ne?" | `teknikPlan.md` | Bölüm 4 — Veritabanı Şeması (zaten `schema.prisma`'ya işlendi, ama okuması kolay) |
| "İş kuralı (BR-x) nerede uygulanacak?" | `teknikPlan.md` | Bölüm 5 |
| "Endpoint'ler ne olmalı?" | `teknikPlan.md` | Bölüm 6 — REST API referansı |
| "Klasör yapısı, katman derinliği, modül sınırı kuralları" | `izlence-typescript-nestjs(1).md` | Bölüm 1-3 |
| "Adım adım kim ne zaman ne yapıyor?" | `izlence-typescript-nestjs(1).md` | Bölüm 7 |
| "Değişmez mimari kuralları neler?" | `CLAUDE.md` (docs/) | tamamı — kısa, oturum başında otomatik okunur |
| "Ekranın tasarımı nasıl olmalı?" | Berzan'ın paylaştığı mockup görselleri + **asb.com** (gerçek kurumsal site, içerik/bölüm yapısı referans alınıyor) | Ekran bazlı, Berzan'dan iste |

---

## 6. Senin İlk Adımın — FAZ 1 / Adım 5

İzlenceye göre sıradaki adımların (Berzan'ın Adım 4 - `auth` - ile **paralel**, onu beklemene gerek yok):

**Adım 5 — `banner`, `is-ortaklari`, `duyuru` modülleri + Ana Sayfa ekranı**

Bu üç modül de **2 katmanlı** (`domain` + `adapters`, `application` yok — basit CRUD, karmaşık iş kuralı yok, `duyuru` için sadece BR-4: "sadece admin oluşturabilir").

Her modülde **Modül Geliştirme Protokolü**nü sırayla uygula (CLAUDE.md'de de özetli):

1. **(a) Sözleşme:** İş mantığına hiç girmeden önce, `packages/shared-types/src/` altına DTO'ları tanımla (örn. `duyuru.types.ts` içinde `DuyuruResponse`, `DuyuruOlusturDto`). Backend tarafında endpoint'lerin şeklini (`GET /api/v1/duyurular`, `POST /api/v1/duyurular` vb.) belirle — `teknikPlan.md` Bölüm 6'daki taslak zaten var, birebir kopyalama, ihtiyaca göre uyarla.
2. **(b) Hemen paylaş:** Bu DTO'ları küçük bir PR ile `develop`'a merge et — iş mantığı yokken bile bu adım kimseyi beklemez, hızlı onaylanır.
3. **(c)/(d):** Bağımlı olduğun başka bir modül yok bu adımda (banner/is-ortaklari/duyuru bağımsız), doğrudan `domain` (entity/enum) + `adapters/persistence` (Prisma repository) + `adapters/web` (Controller) yazımına geç.
4. Mobile tarafında: Ana Sayfa ekranını (`app/(tabs)/index.tsx`) mockup'taki "Hızlı Erişim", "Öne Çıkanlar", "İş Ortakları" bölümleriyle doldur — API'den veri çekmeden önce sabit (mock) veriyle UI'ı kur, sonra `src/core/api/client.ts` üzerinden gerçek endpoint'e bağla.

**Sonraki adımın (Adım 7):** Berzan'ın `auth` modülü bitince (Adım 4), `authStore`'dan `rol` okuyarak Profil ekranı ve `app/(admin)/` route grubunun iskeletini tamamlayacaksın — bu adım Berzan'ı bekler.

---

## 7. Dikkat Edilecek Sabit Kurallar (özet — tamamı `CLAUDE.md`'de)

- `domain` ve `adapters` katmanlarında (senin modüllerin `application` katmanı yok zaten) NestJS decorator'ı (`@Injectable()` vb.) **sadece** `adapters` ve `.module.ts`'de olabilir — `domain` saf TypeScript kalmalı.
- Modüller arası veri ihtiyacın olursa (şu an senin modüllerinde yok) **asla** başka modülün `persistence`/`domain` klasörüne import atma — sadece `adapters/public/*.port.ts` üzerinden.
- `schema.prisma` tek dosya, ortak — yeni kolon/tablo gerekirse tek başına sessizce değiştirme, küçük bir PR ile Berzan'a haber ver.
- Emin olmadığın bir mimari karar varsa (örn. admin panelinin AdminJS'e geçip geçmeyeceği henüz netleşmedi) **tahmin yürütme, sor.**

---

*Sorular veya takıldığın yerler için Berzan'a doğrudan sor — ikiniz de aynı repoda, `develop`'tan açacağın `feature/duyuru` gibi branch'lerle ilerleyeceksiniz.*
