# ASB Platform — Proje Bağlamı (Claude Code için)

> Bu dosya her oturum başında otomatik okunur. Detaylı gereksinim/mimari/adım planı için `docs/isterler.md`, `docs/teknikPlan.md`, `docs/izlence-typescript-nestjs.md` dosyalarını oku — bu dosya sadece özet ve sabit kurallardır.

## Proje Özeti

Avrupa Serbest Bölgesi için bölge içi firmalar, çalışanlar ve ziyaretçiler için hizmet platformu. Modüller: Auth, Ana Sayfa (banner/duyuru/iş ortağı), Firmalar, İş İlanları, İkinci El Pazar, Cookzone, Acil Durum, Paket Teslimi, Bölge İçi Navigasyon.

## Teknoloji Yığını (kesinleşti, değiştirilmez)

- **Backend:** NestJS + TypeScript, Prisma ORM, PostgreSQL 16
- **Frontend:** React Native + Expo (managed workflow) + TypeScript, Web için `react-native-web`
- **State management:** Zustand
- **HTTP client:** Axios
- **Repo yapısı:** Monorepo (npm workspaces) — `packages/backend`, `packages/mobile`, `packages/shared-types`
- **API versiyonlama:** Tüm endpoint'ler `/api/v1/...` altında

## Mimari Kuralları (asla ihlal etme)

1. **Modül-önce, sonra katman.** Her backend modülü kendi klasöründe: basit modüller (`duyuru`, `banner`, `is-ortaklari`, `harita`, `paket-teslimi`) 2 katman (`domain` + `adapters`); karmaşık modüller (`auth`, `firma`, `is-ilanlari`, `ikinci-el-pazar`, `cookzone`, `acil-durum`) 3 katman (`domain` + `application` + `adapters`).
2. **`domain` ve `application` katmanlarında NestJS decorator'ı YOK.** Saf TypeScript class'lar. Nest'e bağlama (`@Injectable`, `useFactory`) sadece modülün `.module.ts` dosyasında yapılır.
3. **Modüller arası erişim SADECE `adapters/public/*.port.ts` üzerinden.** Bir modül başka bir modülün `domain` veya `persistence` katmanına asla doğrudan import edemez. `eslint-plugin-boundaries` bunu CI'da denetler.
4. **Veritabanı şeması ortaktır, modül bazlı değil.** `schema.prisma` tek dosyadır ve tüm 15 tablo FAZ 0'da birlikte, tek seferde tanımlandı (bkz. `docs/teknikPlan.md` Bölüm 4). Yeni bir tablo/kolon gerekirse bu küçük, hızlı bir PR ile yapılır — sessizce, tek başına değiştirilmez.
5. **Dosya depolama** `shared/infrastructure/file-storage/file-storage.port.ts` arkasında soyutlanır (şu an: yerel disk implementasyonu).
6. **API versiyonlama, hata formatı, response zarfı** `shared/web/` altında tek yerde tanımlıdır, her modül bunu tekrar üretmez.

## Modül Geliştirme Protokolü (her yeni modülde uygulanır)

Bir modüle başlarken bu sırayla ilerle:
- **(a) Sözleşme:** `adapters/public/*.port.ts` arayüzü + `packages/shared-types` içine ilgili DTO'lar — iş mantığı yok, sadece şekil
- **(b) Hemen paylaş:** küçük PR, hızlı merge
- **(c) Bağımlı olduğun modül henüz yoksa:** geçici sahte (fake) implementasyon yaz, kendi işine devam et
- **(d) Gerçek implementasyon:** `application`/`persistence` kodu tamamla, sahteyi gerçeğe bağla, PR aç

## Ekip ve İş Bölümü

2 kişilik ekip, **dikey bölünme** (her kişi kendi modülünün hem backend hem frontend tarafını uçtan uca yazar):
- **Kişi A:** `auth`, `firma`, `is-ilanlari`, `cookzone`, `harita`
- **Kişi B:** `duyuru`, `banner`, `is-ortaklari`, `ikinci-el-pazar`, `acil-durum`, `paket-teslimi`

Detaylı adım adım plan (girdi/çıktı/bağımlılık tablosu) → `docs/izlence-typescript-nestjs.md` Bölüm 7.

## Henüz Kesinleşmemiş Kararlar (soru sormadan varsayma)

- **Admin paneli:** Şu an plan "React Native içinde rol bazlı `app/(admin)/` route grubu" diyor, ama **AdminJS**'e geçiş konuşuluyor, kesinleşmedi. Bu konuda kod yazmadan önce sor.
- **Zorunlu paket/kütüphane listesi:** Taslak hazırlanıyor, henüz `isterler.md`'ye eklenmedi.

## Kod Yazarken

- Her yeni dosya/karar bu dosyadaki kurallarla çelişiyorsa, **önce dur ve sor** — tahmin yürütüp ilerleme.
- SOLID/KISS/DRY ilkelerinden ödün verme; basit modüle gereksiz katman ekleme.
- Flutter değil, **React Native/Expo** kullanılıyor — eski örnekler/eğitimlerdeki Flutter kod desenlerini kopyalama.

## Alınan Kararlar (sohbet geçmişi yerine buraya yazılır)

- **21.07.2026 sonrası — Auth OAuth kapsamı:** `auth` modülü Adım 4'te önce e-posta/şifre + JWT ile bitirilecek (Seçenek 1). Google/LinkedIn/Apple OAuth aynı modülün alt-adımı (4b) olarak, sağlayıcı hesapları (client ID/secret) hazır olduğunda eklenecek. US-001'in sosyal giriş kabul kriteri bu ara dönemde "bekliyor" olarak işaretlenir, mentöre bu şekilde raporlanır.


## Alınan Kararlar

- **OAuth (Google/LinkedIn/Apple):** Adım 4b'ye ertelendi — önce e-posta/şifre + JWT tamamlandı. "Beni Hatırla" ve "Şifremi Unuttum" da aynı alt-adımda ele alınacak.
- **Token saklama (mobile):** AsyncStorage değil `expo-secure-store` (web'de localStorage fallback) — JWT şifreli saklanmalı.
- **CORS:** Geliştirme için `origin: true` açıldı (main.ts). FAZ 4/Adım 15'te gerçek domain listesiyle sınırlanacak.
- **main.ts düzeltmesi:** `setGlobalPrefix('api')` eklendi — endpoint'ler artık gerçekten `/api/v1/...` altında.
- **Expo Router açılış:** `app/index.tsx` → `(tabs)`'a Redirect ((admin)/(tabs) çakışması çözümü).
- **UI notu:** Giriş/kayıt ekranları fonksiyonel iskelet — mockup'a görsel uyum ayrı bir UI adımında yapılacak.