# ASB Platform — Proje Bağlamı (Claude Code için)

> Bu dosya her oturum başında otomatik okunur. Detaylı gereksinim/mimari/adım planı için `docs/isterler.md`, `docs/teknikPlan.md`, `docs/izlence-typescript-nestjs(1).md` dosyalarını oku — bu dosya sadece özet ve sabit kurallardır.
>
> **Yeni modül açarken uygulama tarifi:** `docs/YENI-MODUL-REHBERI.md` (hangi dosya nereye, hangi sırayla, kontrol listesi).

## Proje Özeti

Avrupa Serbest Bölgesi için bölge içi firmalar, çalışanlar ve ziyaretçiler için hizmet platformu. Modüller: Auth, Ana Sayfa (banner/duyuru/iş ortağı), Firmalar, İş İlanları, İkinci El Pazar, Cookzone, Acil Durum, Palet Tesisi, Bölge İçi Navigasyon.

## Teknoloji Yığını (kesinleşti, değiştirilmez)

- **Backend:** NestJS + TypeScript, Prisma ORM, PostgreSQL 16
- **Frontend:** Flutter (Dart) — 27.07.2026'da mentör talimatıyla React Native/Expo'dan geçildi. State management: Riverpod, routing: go_router, HTTP client: dio, token saklama: flutter_secure_storage.
- **Repo yapısı:** Monorepo (npm workspaces) — `packages/backend`, `packages/app` (aktif Flutter frontend'i), `packages/shared-types`. `packages/app` npm workspace'i DEĞİLDİR (Flutter paketi, `flutter pub get` kullanır) — kök `package.json`'daki workspaces listesi bilerek açık liste, glob değil. Eski Expo kodu (`packages/mobile`) 28.07.2026'da silindi.
- **API versiyonlama:** Tüm endpoint'ler `/api/v1/...` altında

## Mimari Kuralları — Backend (asla ihlal etme)

1. **Modül-önce, sonra katman.** Her backend modülü kendi klasöründe: basit modüller (`duyuru`, `banner`, `is-ortaklari`, `harita`, `palet-tesisi`) 2 katman (`domain` + `adapters`); karmaşık modüller (`auth`, `firma`, `is-ilanlari`, `ikinci-el-pazar`, `cookzone`, `acil-durum`) 3 katman (`domain` + `application` + `adapters`).
2. **`domain` ve `application` katmanlarında NestJS decorator'ı YOK.** Saf TypeScript class'lar. Nest'e bağlama (`@Injectable`, `useFactory`) sadece modülün `.module.ts` dosyasında yapılır.
3. **Modüller arası erişim SADECE `adapters/public/*.port.ts` üzerinden.** Bir modül başka bir modülün `domain` veya `persistence` katmanına asla doğrudan import edemez. `eslint-plugin-boundaries` bunu CI'da denetler.
4. **Veritabanı şeması ortaktır, modül bazlı değil.** `schema.prisma` tek dosyadır ve tüm 15 tablo FAZ 0'da birlikte, tek seferde tanımlandı (bkz. `docs/teknikPlan.md` Bölüm 4). Yeni bir tablo/kolon gerekirse bu küçük, hızlı bir PR ile yapılır — sessizce, tek başına değiştirilmez.
5. **Dosya depolama** `shared/infrastructure/file-storage/file-storage.port.ts` arkasında soyutlanır (şu an: yerel disk implementasyonu).
6. **API versiyonlama, hata formatı, response zarfı** `shared/web/` altında tek yerde tanımlıdır, her modül bunu tekrar üretmez. **Her controller `ApiResponseDto.ok(...)` döner** — çıplak dizi/nesne dönülmez.
7. **Gövde alan her DTO'da class-validator kuralı vardır ve her decorator'a Türkçe `message` yazılır.** Global `ValidationPipe` açıktır (`whitelist: true, transform: true`); Flutter `error.message`'ı kullanıcıya olduğu gibi gösterdiği için İngilizce varsayılan mesaj bırakmak hatadır.

## Mimari Kuralları — Flutter (asla ihlal etme)

Backend'deki "domain/application saf mantık, framework kodundan ayrı" felsefesinin frontend karşılığı:

8. **Feature bazlı klasörleme:** Her modül `packages/app/lib/features/<modul>/` altında `data/` + `domain/` + `presentation/{durum,ekranlar,widgets}/` şeklinde ayrılır.
9. **`domain/` saf Dart'tır** — `package:flutter/...`, `dio`, `riverpod` import etmez. İş kuralları (validasyon, "bu tıklanabilir mi", girdi temizleme) burada yaşar ve widget/sunucu olmadan test edilir.
10. **Widget'lar sadece görünümdür.** Widget içinde: doğrudan API/dio çağrısı, `launchUrl` gibi platform I/O, `try/catch (ApiHata)`, elle `bool _yukleniyor` yönetimi, `.trim()` gibi girdi normalizasyonu, `if/else` ile iş kuralı kontrolü **olmaz** — hepsi notifier/domain/data'ya taşınır.
11. **State ve akış Riverpod'dadır.** Form gönderen akışlar `core/durum/islem_durumu.dart` içindeki `FormNotifier`'dan türer (yükleniyor durumu, hata yakalama ve çift tıklama koruması oradan gelir); veri okuma akışları `FutureProvider` kullanır.
12. **API çağrıları sadece `data/` katmanında** ve `core/network/api_istegi.dart` içindeki `apiIstegi()` üzerinden yapılır — zarf çözme/hata çevirme her modülde tekrar yazılmaz.
13. **Backend `error.message` doğrudan gösterilir.** Kod→metin eşleme tablosu yazılmaz; mesaj zaten Türkçe ve kullanıcıya yöneliktir.

## Sözleşme Zinciri (shared-types → backend → Dart)

`packages/shared-types` tek kaynaktır. Dart bu TS paketini **import edemez**, bu yüzden `packages/app/lib/core/models/` altında elle ayna tutulur. Bir tip değişirse **aynı PR'da** üç yer birden güncellenir: `shared-types` → backend DTO/entity → Dart modeli. Her Dart model dosyasının başında hangi TS dosyasından türediği yorumla yazılıdır; `packages/app/test/core/auth_modelleri_test.dart` bu çözümlemeyi korur.

## Modül Geliştirme Protokolü (her yeni modülde uygulanır)

Bir modüle başlarken bu sırayla ilerle:
- **(a) Sözleşme:** `adapters/public/*.port.ts` arayüzü + `packages/shared-types` içine ilgili DTO'lar — iş mantığı yok, sadece şekil
- **(b) Hemen paylaş:** küçük PR, hızlı merge
- **(c) Bağımlı olduğun modül henüz yoksa:** geçici sahte (fake) implementasyon yaz, kendi işine devam et
- **(d) Gerçek implementasyon:** `application`/`persistence` kodu tamamla, sahteyi gerçeğe bağla, PR aç

Adım adım dosya/klasör tarifi ve kontrol listesi → `docs/YENI-MODUL-REHBERI.md`.

## Ekip ve İş Bölümü

2 kişilik ekip, **dikey bölünme** (her kişi kendi modülünün hem backend hem frontend tarafını uçtan uca yazar):
- **Kişi A:** `auth`, `firma`, `is-ilanlari`, `cookzone`, `harita`
- **Kişi B:** `duyuru`, `banner`, `is-ortaklari`, `ikinci-el-pazar`, `acil-durum`, `palet-tesisi`

Detaylı adım adım plan (girdi/çıktı/bağımlılık tablosu) → `docs/izlence-typescript-nestjs(1).md` Bölüm 7.

## Henüz Kesinleşmemiş Kararlar (soru sormadan varsayma)

- **Zorunlu paket/kütüphane listesi:** Taslak hazırlanıyor, henüz `isterler.md`'ye eklenmedi.

## Kesinleşen Kararlar (05.08.2026 sonrası)

- **Admin paneli:** **AdminJS**'e karar verildi (React Native/Flutter içinde rol bazlı `app/(admin)/` route grubu fikri elendi). Firma onay akışı (`PUT /firmalar/:id/onayla`) ve ileride duyuru yetki yönetimi AdminJS panelinden yapılacak. Flutter tarafında admin rotası **bilerek kurulmuyor**. AdminJS kurulumu ayrı bir görev (Adım 6b, bkz. `izlence-typescript-nestjs(1).md` Bölüm 7).

## Kod Yazarken

- Her yeni dosya/karar bu dosyadaki kurallarla çelişiyorsa, **önce dur ve sor** — tahmin yürütüp ilerleme.
- SOLID/KISS/DRY ilkelerinden ödün verme; basit modüle gereksiz katman ekleme.
- React Native/Expo değil, **Flutter (Dart)** kullanılıyor (27.07.2026'dan itibaren). Eski Expo kodu silindi; tasarım sabitleri ve geçiş karşılıkları için `izlence-typescript-nestjs(1).md` **Ek A**'ya bak.
- **Anlatım tarzı (05.08.2026 — Berzan'ın talebi):** Berzan bu projeyi yardımsız kurabilmeyi ve staj komisyonuna/mentörüne sistem tasarımını anlatabilmeyi öğrenmek istiyor. Bu yüzden her kod değişikliğinde/komutta sadece "ne yapıldığı" değil, **"neden bu mimari/desen seçildiği"** açıklanmalı: hangi katmana neden konuldu, bağımlılık yönü ne, aynı desen projede başka nerede kullanıldı, alternatifi ne olurdu. Satır satır ezber değil, sistem mühendisliği muhakemesi hedefleniyor — bu, C#'tan geçiş yapan ve hiçbir şey bilmiyormuş gibi öğretilmek isteyen Berzan'ın standart talimatının bir uzantısı.

---

## Bilinen Ortam Sorunları (her yeni sohbette/makinede tekrar keşfetme)

- **`packages/shared-types` değiştiğinde derlenmiş kod eski kalır:** Bu paket kaynaktan değil, derlenmiş `dist/` klasöründen okunuyor. Bir `.ts` dosyasını (örn. `auth.types.ts`) değiştirdikten sonra `npm run build --workspace=@asb/shared-types` çalıştırılmadan backend "has no exported member" hatası verir. `nest start --watch` bu değişikliği otomatik yakalamaz — build'den sonra backend'i elle yeniden başlat (`Ctrl+C` + `npm run dev:backend`).
- **Windows'ta EPERM / "cannot delete directory" hataları (Flutter `ios/Flutter/ephemeral`, `build/`; backend `dist/`):** Sebep genelde Windows Defender'ın gerçek zamanlı taraması — Flutter/Node çok sayıda dosyayı hızlıca yazıp silerken Defender araya girip anlık kilitliyor (Visual Studio'daki `obj`/`bin` kilitlenmesiyle aynı kök sebep). Kalıcı çözüm: proje klasörünü (`C:\Dev\AppforASB` ya da eşdeğeri) Windows Güvenliği → Virüs ve tehdit koruması → Ayarları yönet → Dışlamalar'a klasör olarak eklemek. Eklenene kadar geçici çözüm: ilgili klasörü silip tekrar dene (`Remove-Item -Recurse -Force <klasör>` ya da daha agresif `cmd /c "rmdir /s /q <klasör>"`). Proje klasörü OneDrive gibi bulut senkronizasyonlu bir yerdeyse (eskiden yaşandı) aynı belirtiler çıkar — klasörün senkronize olmadığından da emin ol.
- **06.08.2026 — `flutter test` özellikle bu kilide takılıyor (`ios/Flutter/ephemeral/Packages/.packages` silinemiyor), önceki maddedeki genel klasör-temizleme geçici çözümü burada işe YARAMIYOR** — çünkü kilitlenen dosyayı ben değil, `flutter test`'in kendi `pub get` adımı çalışırken tekrar yaratıp siliyor (yeniden deneme/klasör silme öncesinde yapılsa da fark etmiyor, 5 kez denenip doğrulandı). Asıl geçici çözüm: `flutter test --no-pub` (ve gerekirse `flutter analyze` için de aynısı) — pub get adımını atlayıp ephemeral klasörünü hiç yeniden yazdırmıyor. Bağımlılıklar zaten değişmediyse (`pubspec.yaml` aynıysa) bu güvenli.

## Alınan Kararlar (sohbet geçmişi yerine buraya yazılır)

### Auth / kimlik doğrulama

- **21.07.2026 sonrası — Auth OAuth kapsamı:** `auth` modülü Adım 4'te önce e-posta/şifre + JWT ile bitirilecek (Seçenek 1). Google/LinkedIn/Apple OAuth aynı modülün alt-adımı (4b) olarak, sağlayıcı hesapları (client ID/secret) hazır olduğunda eklenecek. US-001'in sosyal giriş kabul kriteri bu ara dönemde "bekliyor" olarak işaretlenir, mentöre bu şekilde raporlanır. Flutter'daki sosyal giriş düğmeleri şu an "Yakında" mesajı gösteriyor.
- **US-001 sapması (kayıt akışı):** `isterler.md`'de "kayıt sonrası otomatik giriş" kabul kriteri vardı, bilinçli olarak değiştirildi — kayıt sonrası kullanıcı otomatik oturum açmıyor, `/giris` ekranına yönlendirilip elle giriş yapıyor. Sebep: ürün tercihi (Berzan). Kuralın kod içindeki yeri: `packages/app/lib/features/auth/presentation/durum/kayit_notifier.dart` (bilerek `authProvider`'a dokunmaz).
- **Beni Hatırla:** İşaretliyse JWT 30 gün, işaretsizse 1 gün geçerli oluyor (`JwtTokenUreticiAdapter`). Flutter tarafında ek iş yok, backend hallediyor.
- **Şifremi Unuttum:** JWT tabanlı, 15 dakika geçerli, tek amaçlı ("sifre-sifirlama" claim'i) token ile çalışıyor. E-posta gönderimi Mailtrap (geliştirme) üzerinden, `EMAIL_HOST/PORT/USER/PASS` env değişkenleriyle.
- **Token saklama:** Flutter'da `flutter_secure_storage` (web'de şifreli localStorage). Oturum kaydı tek JSON olarak `asb-auth` anahtarında tutulur — eski Expo'daki zustand `persist` deseniyle aynı anahtar/şekil.

### Backend

- **CORS:** Geliştirme için `origin: true` açıldı (main.ts). FAZ 4/Adım 15'te gerçek domain listesiyle sınırlanacak.
- **main.ts düzeltmesi:** `setGlobalPrefix('api')` eklendi — endpoint'ler artık gerçekten `/api/v1/...` altında.
- **27.07.2026 — Global `ValidationPipe` devreye alındı:** DTO'lardaki class-validator kuralları (`register.dto.ts`'teki `@MinLength(8)` + `@Matches(/\d/)` dahil) **hiç çalışmıyordu** — `main.ts`'te `useGlobalPipes` satırı yoktu. `POST /auth/register`'a 4 karakterlik şifre gönderilince 200 dönüyor ve kullanıcı oluşuyordu; yani US-001'in "min 8 karakter + 1 rakam" kabul kriterini tutan tek şey Flutter'daki ipucu metniydi. `main.ts`'e `ValidationPipe({ whitelist: true, transform: true })` eklendi. **Zarf bozulmadı:** `GlobalExceptionFilter` zaten ValidationPipe'ın `message` dizisini birleştirip `ApiResponseDto.fail`'e sarıyor. **Zamanlama gerekçesi:** o gün gövde DTO'su olan sadece 4 auth endpoint'i vardı; yeni modüller "validasyon çalışıyor" varsayarak DTO yazdıkça pipe'ı sonradan açmak tek seferde onlarca endpoint'i kıracaktı. **Yan kazanç:** `whitelist: true` DTO'da tanımsız alanları düşürüyor — gövdeye `"rol":"admin"` enjekte etme denemesi etkisiz (kullanıcı `ziyaretci` açılıyor). **Ek iş:** 4 auth DTO'sundaki tüm decorator'lara Türkçe `message` yazıldı. **Kalan boşluk:** `@IsNotEmpty` yok, `ad`/`soyad` boş string (`""`) veya sadece boşluk olarak geçebiliyor — ayrıca ele alınacak.
- **27.07.2026 — Banner endpoint zarfı düzeltmesi:** `BannerController`'ın `GET /banners` endpoint'i düz `BannerData[]` dönüyordu, `ApiResponseDto.ok(...)` zarfını kullanmıyordu (tutarsızlık). Flutter'daki tek response şekli beklentisi için zarfa sarıldı.
- **28.07.2026 — `shared/domain/base-entity.ts` silindi:** Hiçbir entity kullanmıyordu (`Kullanici` de extend etmiyordu) ve vaat ettiği `id`/`olusturmaTarihi` ortaklığı gerçek entity'lerde karşılık bulmuyordu (`banner`'da tarih alanı yok, `duyuru`'da `yayinTarihi` var). Ölü soyutlama bırakmak yerine kaldırıldı; gerçekten ortak bir taban gerekirse o zaman, gerçek ihtiyaca göre yazılır.

### Frontend (Flutter)

- **27.07.2026 — Frontend: React Native/Expo'dan Flutter'a geçiş:** Mentör talimatıyla (zorunlu, tartışmaya kapalı) frontend Flutter (Dart) ile yeniden yazılıyor. Gerekçe proje tercihi değil, mentör kararı. Yeni frontend `packages/app` altında; kütüphaneler: Riverpod (state), go_router (routing), dio (HTTP), flutter_secure_storage (token saklama). `packages/mobile` (eski Expo kodu) o tarihte referans olarak bırakılmıştı; **28.07.2026'da silindi** — aşağıdaki maddeye bakınız.
- **27.07.2026 — Banner özelliğinin gerçek durumu:** Backend (`GET /banners`, Prisma `banner` tablosu) çalışır durumdaydı ama eski Expo'daki banner bileşeni backend'e hiç bağlı değildi — 3 sabit metin banner'ıyla, 2 saniyede bir otomatik kayan, alt nokta göstergeli bir UI mockup'ıydı. Flutter portu bu carousel mekaniğini (PageView + Timer + dot indicator) yeniden kurdu VE gerçekten `GET /banners`'a bağladı — projedeki ilk uçtan uca entegrasyon.
- **27.07.2026 — Paylaşılan tiplerin Dart tarafına manuel yansıtılması (mirror):** `packages/shared-types` bir TypeScript paketi; Dart'tan import edilemiyor. Bu yüzden sözleşmedeki tipler `packages/app/lib/core/models/` altında EL İLE yazılmış Dart karşılıklarıyla yansıtılıyor; her dosyanın başında kaynak TS dosyası yorumla belirtili. **Gerekçe:** yansıtılan yüzey küçük (auth + banner, ~8 tip), elle senkron tutmak codegen altyapısı kurmaktan ucuz. **Kural:** `shared-types` içindeki bir tip değişirse Dart karşılığı AYNI PR'da güncellenir; `packages/app/test/core/auth_modelleri_test.dart` JSON çözümlemesini korur. **Sınır:** modül sayısı artınca (firma, iş ilanları, ikinci el pazar, cookzone…) manuel mirror sürdürülebilir olmaktan çıkar — o noktada Swagger/OpenAPI'den Dart model codegen'ine (`openapi-generator` / `swagger_parser` benzeri) geçiş **ayrıca konuşulacak**, şimdiden kurulmuyor.
- **28.07.2026 — Derin link (deep link) düzeltmesi:** Oturum güvenli depodan okunana kadar ayrı bir `MaterialApp` (yükleme ekranı) gösteriliyordu. Router'sız bu `MaterialApp` kendi `Navigator`'ını kurup web'de tarayıcı adresini `/` olarak yeniden yazıyor, e-postadaki `/sifre-sifirla?token=...` linki daha router görmeden kayboluyordu — soğuk açılışta tüm auth rotaları `/giris`'e düşüyordu. Çözüm: `MaterialApp.router` her zaman kurulu, bekleme göstergesi `SekmeKabugu` içine alındı. Ayrıca `GoRouter`'a sabit `initialLocation` verilmiyor — web'de tarayıcı adresi tek yetkili kaynak. Regresyon testi: `packages/app/test/core/yonlendirici_test.dart`.
- **28.07.2026 — Sıfırlama linki tabanı:** Backend e-postada `http://localhost:8081/sifre-sifirla?token=...` gönderiyor (eski Expo portu, path stili). Flutter web hash routing kullanıyor: `http://localhost:5000/#/sifre-sifirla?token=...`. Kod değişikliği gerekmiyor, `SIFIRLAMA_LINK_TABANI` env değişkeni Flutter'ın adresine ayarlanmalı. Native derin link (`asbplatform://`) ileride aynı değişkenle devreye alınabilir.
- **28.07.2026 — Frontend katmanlama refactor'ü:** Ekranlar doğrudan `authApiProvider` çağırıyor, `launchUrl` widget içinde duruyor, her ekran kendi `bool _yukleniyor` + `try/catch` üçlüsünü tekrar ediyordu. Backend'deki katman felsefesinin karşılığı kuruldu: her feature `data/` + `domain/` + `presentation/{durum,ekranlar,widgets}/` şeklinde ayrıldı, ortak `FormNotifier`/`IslemDurumu` tabanı ve `apiIstegi()` zarf çözücüsü eklendi. Yan kazanç: çift tıklama koruması artık tek yerde ve tüm formlarda geçerli. Uygulama tarifi → `docs/YENI-MODUL-REHBERI.md`.
- **28.07.2026 — Banner linki güvenlik sıkılaştırması:** `banner.linkUrl` artık yalnızca **mutlak http/https** adresi ise açılıyor (`features/ana_sayfa/domain/banner_kurallari.dart`); `javascript:`, `file:` gibi şemalar ve göreli yollar reddediliyor. Banner verisi ileride admin panelinden girileceği için sınır domain katmanında ve testli.
- **30.07.2026 — "Paket Teslimi" → "Palet Tesisi" isim düzeltmesi:** FAZ 0'da 15 tablo tek seferde tanımlanırken bu modülün adı yanlış okunmuş/yazılmış — proje sahibinin asıl niyeti "Palet Tesisi" idi. Modül Faz 3'te henüz hiç yazılmadığı (backend'de boş `@Module({})` iskeleti, Flutter'da sadece Ana Sayfa'daki Hızlı Erişim ikonu) için bu bir **isim düzeltmesi**, geri uyumluluk kaygısı yok. Değişenler: Prisma `model PaketTeslimi`→`PaletTesisi`, `enum PaketTeslimiDurumu`→`PaletTesisiDurumu`, `@@map("paket_teslimi")`→`@@map("palet_tesisi")`, `Kullanici`/`BolgeNoktasi` üzerindeki `paketTeslimleri`→`paletTesisleri` ilişki alanları; backend `modules/paket-teslimi/`→`modules/palet-tesisi/` (klasör+dosya+sınıf); Flutter `HizliErisimModulu.paketTeslimi`→`paletTesisi` ve ikonu (`local_shipping_outlined` teslimat kamyonu→`inventory_2_outlined` envanter/palet, isimle tutarlı olsun diye); `docs/` içindeki 6 dosyadaki tüm geçişler. **BİLEREK değiştirilmeyen:** Prisma modelindeki alan adları (`kargoFirmasi`, `takipNo`, `teslimNoktasi`) ve durum enum değerleri (`beklemede`/`bolgede`/`teslim_edildi`) — bunlar hâlâ "kargo/paket takibi" iş akışını tarif ediyor, "palet tesisi" (depo/envanter) kavramına tam oturmuyor olabilir. Modül gerçekten Faz 3'te yazılırken bu alanların da gözden geçirilmesi gerekecek; şimdilik sadece isim/etiket düzeltildi, iş kuralı tasarımı yapılmadı. **DB migration:** yeni bir `prisma migrate dev` migration'ı ile tablo/enum adı canlı geliştirme veritabanında da yeniden adlandırıldı (henüz veri yoktu, kayıp riski yok).
