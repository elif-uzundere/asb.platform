# Elif için Başlangıç Rehberi — ASB Platform

> Bu doküman `isterler.md`, `teknikPlan.md` ve `izlence-typescript-nestjs(1).md` dosyalarının **özeti + şu anki durum + senin ilk adımların** için hazırlandı. Detaya indiğinde her zaman o üç dosyaya (ve `CLAUDE.md`'deki sabit mimari kurallarına) dön — burada sadece yol haritasını görüyorsun.
>
> **28.07.2026 güncellemesi:** Mentör talimatıyla mobile frontend Expo/React Native'den **Flutter**'a geçildi (zorunlu, ikimiz için de geçerli) ve Flutter tarafı artık **kurulu ve çalışıyor** — `packages/app` altında auth (giriş/kayıt/şifre sıfırlama/profil) + ana sayfa banner'ı yazıldı. Backend (NestJS) değişmedi. Eski Expo kodu (`packages/mobile`) **28.07.2026'da silindi** — geçiş karşılıkları ve tasarım sabitleri `izlence-typescript-nestjs(1).md` → **Ek A**'da arşivli.
>
> **Yeni modül açarken ilk okuyacağın dosya: `docs/YENI-MODUL-REHBERI.md`** — hangi dosya nereye, hangi sırayla, kopyalanabilir kod örnekleriyle. Aşağıdaki Bölüm 6 seni oraya yönlendiriyor.

---

## 1. Ekip ve Roller

| Kişi | Rol | Sorumlu olduğu modüller (hem backend hem mobile, uçtan uca) |
|------|-----|----------------------------------------------------------|
| **Berzan (Kişi A)** | Backend + Mobile | `auth`, `firma`, `is-ilanlari`, `cookzone`, `harita` |
| **Elif (Kişi B)** | Backend + Mobile | `duyuru`, `banner`, `is-ortaklari`, `ikinci-el-pazar`, `acil-durum`, `paket-teslimi` |

**Dikey bölünme** kullanılıyor — yani kendi modülünün hem NestJS (backend) hem Flutter (mobile, 27.07.2026'dan itibaren) tarafını sen yazıyorsun. API şeklini "tahmin etmen" gerekmiyor çünkü sözleşmeyi (DTO/port) de sen yazacaksın (aşağıda Bölüm 5).

---

## 2. Şu Anki Durum (FAZ 0 — tamamlandı ✓)

Aşağıdakiler zaten kurulu ve `develop` branch'inde:

- ✅ Monorepo: `packages/shared-types` + `packages/backend` (npm workspaces) ve `packages/app` (Flutter — npm ile yönetilmiyor, `flutter pub get` kullanır)
- ✅ Backend: NestJS proje yapısı, 11 modülün klasör iskeleti (`domain`/`application`/`adapters` — karmaşıklığa göre 2 veya 3 katman), `eslint-plugin-boundaries` kuralları
- ✅ **Veritabanı şeması — 15 tablonun tamamı** `packages/backend/prisma/schema.prisma` içinde tanımlı **ve** `prisma migrate dev` ile gerçek PostgreSQL'de (boş tablolar olarak) oluşturulmuş durumda
- ✅ Swagger (`/api/v1/docs`), `/api/v1` versiyonlama, `GlobalExceptionFilter`, health check (`/api/v1/health`), `FileStoragePort` + yerel disk adapter'ı
- ✅ **Flutter uygulaması (`packages/app`) kurulu ve çalışıyor:** go_router + ShellRoute ile 5 sekme (Ana Sayfa, Firmalar, Harita, Duyurular, Profil), Riverpod state, dio + token interceptor, flutter_secure_storage
- 🗑️ **Eski Expo kodu silindi (28.07.2026)** — her `npm install`'da gereksiz Expo/React Native bağımlılığı indiriyordu. Renk paleti, banner/form ölçüleri gibi tasarım sabitleri `izlence-typescript-nestjs(1).md` **Ek A**'da; kodun kendisi git geçmişinde.
- ✅ `docker-compose.yml` (PostgreSQL 16, **port 5434** — bilgisayarında yerel bir Postgres kuruluysa 5432 ile çakışmasın diye böyle ayarlandı)
- ✅ GitHub Actions CI (`lint` + `build` + `test`)

### Bitmiş olanlar (örnek olarak inceleyebilirsin)

- ✅ **`auth` modülü** (Berzan) — backend 3 katman + Flutter ekranları. Kayıt, giriş, "beni hatırla", şifremi unuttum, şifre sıfırlama, profil, çıkış. **3 katmanlı modülün referans örneği.**
- ✅ **`banner` modülü + Ana Sayfa carousel'i** — `GET /banners` uçtan uca bağlı. **2 katmanlı modülün ve en sade uçtan uca akışın referans örneği.**
- ✅ Global `ValidationPipe` açık — DTO'lardaki class-validator kuralları artık gerçekten çalışıyor (28.07.2026'da düzeltildi).

**Henüz yapılmadı:** Diğer 9 modülün iş mantığı. `firmalar`, `harita`, `duyurular` sekmeleri Flutter'da sadece başlık gösteren boş yer tutucu.

---

## 3. Bilgisayarına Kurman Gerekenler

| Araç | Neden | Not |
|------|-------|-----|
| **Node.js 20 LTS** | Backend + mobile + workspaces için | [nodejs.org](https://nodejs.org)'dan LTS sürüm |
| **Git** | Versiyon kontrol | — |
| **Docker Desktop** | PostgreSQL'i container'da çalıştırmak için | Windows'ta WSL2 backend önerilir |
| **VS Code** | Ortak editör | Eklentiler: **ESLint**, **Prisma** (syntax highlight), **Flutter** + **Dart** (resmi eklentiler) |
| **Flutter SDK** | Mobile geliştirme | flutter.dev'den kur, `flutter doctor` ile doğrula. Proje **Flutter 3.44 / Dart 3.12** ile yazıldı |
| *(şimdilik gerekli değil)* Android Studio / Android SDK | Emülatör ile test | Şu an geliştirme hedefi **Chrome (web)** — Android/iOS emülatörü Berzan tarafında bilinçli olarak ertelendi, gerekirse ayrı konuşuruz |

**Not:** Backend bağımlılıklarının (NestJS, Prisma, Swagger vb.) hiçbirini tek tek kurmana gerek yok — `packages/backend`'de tek komutla (`npm install`) hepsi gelir. Flutter tarafında paketler `packages/app/pubspec.yaml` içinde tanımlı olacak, `flutter pub get` ile kurulur (npm'in Flutter karşılığı).

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
```

Backend ayaktayken **ayrı bir terminalde** Flutter'ı başlat:

```powershell
cd packages\app
flutter pub get          # npm install'ın Flutter karşılığı
flutter run -d chrome    # Chrome'da açılır, /giris ekranı gelmeli
```

Doğrulama: giriş ekranında "Kayıt ol" → bilgileri gir → kayıt olunca `/giris`'e
dönmelisin (otomatik giriş **yok**, bilinçli karar) → giriş yapınca ana sayfada
banner carousel'in backend'den gelen görsellerle dönmesi lazım.

Faydalı komutlar (hepsi `packages/app` içinden):

```powershell
flutter analyze    # lint — temiz olmalı
flutter test       # birim testler — yeşil olmalı
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
| **"Yeni modül açıyorum, hangi dosya nereye?"** | **`YENI-MODUL-REHBERI.md`** | **tamamı — kopyalanabilir kod örnekleri + kontrol listesi** |
| "Klasör yapısı, katman derinliği, modül sınırı kuralları" | `izlence-typescript-nestjs(1).md` | Bölüm 1-3 |
| "Flutter tarafı nasıl katmanlanıyor, state nerede duruyor?" | `izlence-typescript-nestjs(1).md` | Bölüm 5 |
| "Adım adım kim ne zaman ne yapıyor?" | `izlence-typescript-nestjs(1).md` | Bölüm 7 |
| "Response/hata formatı ne, mesajlar nasıl yazılır?" | `teknikPlan.md` | Bölüm 6 — Response Zarfı |
| "Değişmez mimari kuralları neler?" | `CLAUDE.md` (docs/) | tamamı — kısa, oturum başında otomatik okunur |
| "Ekranın tasarımı nasıl olmalı?" | Berzan'ın paylaştığı mockup görselleri + **asb.com** (gerçek kurumsal site, içerik/bölüm yapısı referans alınıyor) | Ekran bazlı, Berzan'dan iste |

---

## 6. Senin İlk Adımın — FAZ 1 / Adım 5

`banner` modülü ve Ana Sayfa'nın banner carousel'i **Berzan tarafından yazıldı** (Flutter geçişi sırasında örnek olsun diye uçtan uca bağlandı). Senin sıradaki işin:

**Adım 5 (kalan kısmı) — `duyuru` ve `is-ortaklari` modülleri + Ana Sayfa'nın kalan bölümleri**

Her ikisi de **2 katmanlı** (`domain` + `adapters`; `application` yok — basit CRUD, `duyuru` için tek kural BR-4: "sadece admin oluşturabilir").

> **Önce şunu yap:** `docs/YENI-MODUL-REHBERI.md`'yi baştan sona oku. Hangi dosyayı
> nereye yazacağın, kopyalanabilir kod örnekleri ve bitirme kontrol listesi orada.
> Somut örnek görmek istersen: `banner` (basit, 2 katman) ve `auth` (karmaşık, 3 katman)
> modülleri şablonun birebir uygulanmış hâli.

Kısaca sıra:

1. **(a) Sözleşme:** `packages/shared-types/src/duyuru.types.ts` → `DuyuruResponse`, `DuyuruOlusturRequest`. Endpoint şekli için `teknikPlan.md` Bölüm 6'daki taslağa bak.
2. **(b) Hemen paylaş:** küçük PR, hızlı merge.
3. **(d) Backend:** `domain` (entity + repository interface) → `adapters/persistence` (Prisma) → `adapters/web` (DTO + controller). Controller `ApiResponseDto.ok(...)` döner, DTO'daki her kurala **Türkçe `message`** yaz.
4. **Dart aynası:** `packages/app/lib/core/models/duyuru_modelleri.dart` — TS tipinin elle yazılmış karşılığı. Dart, TS paketini import edemiyor; bu yüzden aynı PR'da güncellenir.
5. **Flutter:** `packages/app/lib/features/duyurular/` altında `data/` + `domain/` + `presentation/`. `duyurular_ekrani.dart` şu an boş yer tutucu — onu dolduracaksın.

**Sonraki adımın (Adım 7):** Profil ekranı **yazıldı** (auth ile birlikte geldi). Admin route grubu ise **bilerek kurulmadı** — AdminJS kararı netleşmedi, o iş açılmadan başlama.

---

## 7. Dikkat Edilecek Sabit Kurallar (özet — tamamı `CLAUDE.md`'de)

- `domain` ve `adapters` katmanlarında (senin modüllerin `application` katmanı yok zaten) NestJS decorator'ı (`@Injectable()` vb.) **sadece** `adapters` ve `.module.ts`'de olabilir — `domain` saf TypeScript kalmalı.
- Modüller arası veri ihtiyacın olursa (şu an senin modüllerinde yok) **asla** başka modülün `persistence`/`domain` klasörüne import atma — sadece `adapters/public/*.port.ts` üzerinden.
- `schema.prisma` tek dosya, ortak — yeni kolon/tablo gerekirse tek başına sessizce değiştirme, küçük bir PR ile Berzan'a haber ver.
- Her controller **`ApiResponseDto.ok(...)`** döner; gövde alan her DTO'da class-validator kuralı + **Türkçe `message`** olur (Flutter mesajı kullanıcıya olduğu gibi gösteriyor).
- **Flutter tarafında widget içine iş mantığı yazma:** API çağrısı, `try/catch`, elle `bool _yukleniyor`, `.trim()`, `if/else` kural kontrolü — hiçbiri ekranda durmaz. Sırasıyla `data/`, `FormNotifier`, `domain/` katmanlarına gider (`YENI-MODUL-REHBERI.md` Bölüm 3.5'te "yanlış/doğru" tablosu var).
- `shared-types`'ta bir tip değiştirirsen **Dart aynasını aynı PR'da güncelle** (`packages/app/lib/core/models/`).
- Emin olmadığın bir mimari karar varsa (örn. admin panelinin AdminJS'e geçip geçmeyeceği henüz netleşmedi) **tahmin yürütme, sor.**

---

*Sorular veya takıldığın yerler için Berzan'a doğrudan sor — ikiniz de aynı repoda, `develop`'tan açacağın `feature/duyuru` gibi branch'lerle ilerleyeceksiniz.*
