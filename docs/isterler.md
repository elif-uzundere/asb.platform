# İş Gereksinimleri Dokümanı (BRD)
## Avrupa Serbest Bölgesi — Mobil ve Web Platformu

| Alan | Değer |
|------|-------|
| **Doküman No** | BRD-ASB-2026-001 |
| **Versiyon** | 1.0 |
| **Tarih** | 21.07.2026 |
| **Hazırlayan** | Stajyer / Proje Sahibi |
| **Onaylayan** | Mentor / Bölge Yönetimi |
| **Durum** | Taslak — Fikir alışverişi sonrası hazırlandı |
| **İlgili doküman** | `teknikPlan.md` (veri modeli/API referansı), `izlence-typescript-nestjs.md` (mimari + adım planı) |

---

## 1. Yönetici Özeti

Avrupa Serbest Bölgesi'nde faaliyet gösteren firmaların, çalışanların ve ziyaretçilerin bölgeyle ilgili tüm hizmetlere **tek bir platformdan** ulaşabilmesi hedeflenmektedir. Uygulama; iş ilanları, ikinci el eşya pazarı, firma dizini, bölge içi navigasyon, acil durum bildirimi, yemek siparişi (Cookzone) ve duyurular gibi farklı hizmetleri tek çatı altında toplayan bir **kurumsal hizmet platformu**dur.

Platform **iOS, Android ve Web** için tek kod tabanından **Flutter (Dart)** ile geliştirilecektir — 27.07.2026'da mentör talimatıyla React Native/Expo'dan geçilmiştir (bkz. `docs/CLAUDE.md` Alınan Kararlar). Arka uç **TypeScript (NestJS)** olarak kesinleşmiştir; frontend artık farklı bir dilde (Dart) olduğu için önceki "aynı dilde kalınarak tip paylaşımı" avantajı geçerli değildir — bu konu ayrıca çözülecektir. Veritabanı **PostgreSQL**'dir.

**Proje adı:** ASB Platform (çalışma adı)
**Kaynak:** Bölge yönetiminden gelen mobil uygulama mockup'ı (login + ana sayfa ekranı)
**Hedef kullanıcı kitlesi:** Bölgedeki firma çalışanları, firma yetkilileri, ziyaretçiler, bölge yönetimi (admin)
**Ömür beklentisi:** Uzun vadeli (10 yıl+), zamanla modül eklenerek büyüyecek bir sistem

---

## 2. İş Problemi ve Amaç

### 2.1 Problem
- Bölgedeki firmalar ve çalışanlar hakkında bilgiye dağınık şekilde (farklı kişiler, farklı kanallar üzerinden) ulaşılıyor
- İş ilanları, ikinci el eşya paylaşımı gibi ihtiyaçlar için ortak bir kanal yok
- Acil durumlarda bölge içi hızlı bildirim mekanizması yok
- Bölge içinde firma/bina bulmak (navigasyon) zor
- Duyurular ve iş birlikleri firmalara/çalışanlara düzenli ulaşmıyor

### 2.2 İş Hedefleri

| # | Hedef | Ölçüm |
|---|-------|-------|
| H1 | Bölge hizmetlerinin tek platformda toplanması | Tüm modüller çalışır durumda |
| H2 | Firma ve çalışan bilgilerinin güvenilir şekilde tutulması | Doğrulanmış hesap sistemi (auth) |
| H3 | İş ilanı ve ikinci el pazarının bölge içi güvenle çalışması | Sadece doğrulanmış hesaplar içerik paylaşabilir |
| H4 | Acil durumlarda hızlı bildirim | Bildirim gönderimi + konum bilgisi |
| H5 | Bölge içi gezinmenin kolaylaşması | Harita/navigasyon modülü |
| H6 | Uzun vadeli sürdürülebilirlik | Modüler mimari, temiz kod, dökümante API |

---

## 3. Kapsam

### 3.1 Kapsam içi (Faz 1 — Must Have)

| Modül | Açıklama |
|-------|----------|
| Kimlik Doğrulama (Auth) | E-posta/telefon + şifre ile giriş, Google/LinkedIn/Apple ile giriş, kayıt ol, şifremi unuttum |
| Ana Sayfa | Kayan banner (carousel), Hızlı Erişim ikonları, Öne Çıkanlar, İş Ortakları listesi |
| Firmalar | Bölgedeki firmaların listesi, detay sayfası (adres, iletişim, sektör) |
| Duyurular | Bölge yönetiminden gelen duyuru/haber listesi ve detayı |
| Profil | Kullanıcı bilgileri, firma bağlantısı, ayarlar |

### 3.2 Kapsam içi (Faz 2 — Should Have)

| Modül | Açıklama |
|-------|----------|
| İş İlanları | Firmaların yayınladığı açık pozisyonlar, başvuru |
| İkinci El Pazar | Kullanıcılar arası ikinci el eşya ilanı verme/görüntüleme |
| Bölge İçi Navigasyon | Harita üzerinde firma/bina/giriş-çıkış noktaları |

### 3.3 Kapsam içi (Faz 3 — Could Have)

| Modül | Açıklama |
|-------|----------|
| Cookzone | Bölge içi yemek/kafeterya menüsü ve sipariş |
| Palet Tesisi | Kargo/paket takibi ve teslim bildirimi |
| Acil Durum | Tek dokunuşla acil durum bildirimi, konum paylaşımı |

### 3.4 Kapsam dışı (Won't Have — bu fazda yok)

- Ödeme altyapısı (Cookzone siparişi için gerçek ödeme entegrasyonu — ileride ayrı faz)
- Firma bazlı çoklu şube/çoklu ülke yönetimi
- Gerçek zamanlı canlı sohbet (chat) — ileride değerlendirilebilir
- Push notification altyapısı (Faz 1-3'te yok, ileride eklenebilir)
- Çok dilli destek (i18n) — ileride eklenebilir, mimari buna kapalı olmayacak

### 3.5 Varsayımlar

| # | Varsayım |
|---|----------|
| A1 | İlk fazda tek bir "bölge" (Avrupa Serbest Bölgesi) yönetilecek, çoklu bölge desteği yok |
| A2 | Firma hesapları bölge yönetimi tarafından onaylanarak açılacak (self-servis firma kaydı yok) |
| A3 | Bireysel kullanıcı (çalışan/ziyaretçi) kaydı e-posta doğrulama ile self-servis olabilir |
| A4 | Web sürümü aynı Flutter kod tabanından (Flutter'ın resmi web hedefiyle) üretilecek |
| A5 | Admin paneli ayrı bir arayüz olarak (web üzerinden, aynı backend'e bağlı) düşünülecek |

### 3.6 Kısıtlar

| # | Kısıt |
|---|-------|
| C1 | Frontend: Flutter (Dart) — iOS + Android + Web tek kod tabanı (27.07.2026'da React Native/Expo'dan değişti) |
| C2 | Backend: NestJS (TypeScript) |
| C3 | Veritabanı: PostgreSQL |
| C4 | ORM: Prisma |
| C5 | Kod Git repository'de tutulmalı, `main` branch korunmalı |
| C6 | Tüm API endpoint'leri Swagger'da dokümante edilmeli |
| C7 | İş kuralları sadece frontend'de değil, backend service katmanında da uygulanmalı |
| C8 | Mimari, ileride yeni modül eklemeye ve ekip büyümesine izin verecek şekilde **modüler monolith** olmalı |

---

## 4. Aktörler ve Kullanıcı Rolleri

| Rol | Açıklama | Yetkiler (Faz 1-3) |
|-----|----------|------------------|
| **Ziyaretçi Kullanıcı** | Kayıtlı bireysel kullanıcı, firma bağlantısı yok | Görüntüleme, ikinci el ilanı verme, acil durum bildirimi |
| **Firma Çalışanı** | Bir firmaya bağlı kayıtlı kullanıcı | Ziyaretçi yetkileri + kendi firması adına iş ilanı görme |
| **Firma Yetkilisi** | Firma adına içerik yönetebilen kullanıcı | İş ilanı yayınlama/düzenleme, firma profilini güncelleme |
| **Bölge Yönetimi (Admin)** | Bölge yönetimi çalışanı | Duyuru yayınlama, firma onaylama, iş ortağı ekleme, banner yönetimi, acil durum bildirimlerini görme |

> Faz 1'de rol ayrımı temel seviyede (Ziyaretçi vs Admin) tutulabilir; Firma Yetkilisi rolü Faz 2'de (İş İlanları ile birlikte) devreye girer.

---

## 5. Kullanıcı Hikâyeleri (User Stories)

### Epic 1 — Kimlik Doğrulama

**US-001 — Kayıt olma**
> **Kullanıcı olarak**, e-posta/telefon ve şifremle **veya** Google/LinkedIn/Apple ile kayıt olabilmek **istiyorum**, **böylece** platforma hızlıca erişebilirim.

**Kabul kriterleri:**
- [x] E-posta formatı doğrulanır, aynı e-posta ile ikinci kayıt engellenir (409)
- [x] Şifre minimum güvenlik kuralına uyar (min 8 karakter, en az 1 rakam) — *backend'de `ValidationPipe` ile zorlanıyor (28.07.2026'da devreye alındı; öncesinde kural yazılıydı ama çalışmıyordu)*
- [ ] Sosyal giriş seçeneklerinden biri seçildiğinde ilgili OAuth akışı başlar — **KISMEN**: Google ile giriş uçtan uca yazıldı (05.08.2026 — backend `POST /auth/google-giris`, google-auth-library ile ID token doğrulama, hesap yoksa otomatik/şifresiz açılıyor; Flutter'da `google_sign_in` entegre, web'de Google'ın kendi düğmesi, mobilde native akış) ama henüz gerçek bir Google hesabıyla canlı tıklanarak doğrulanmadı. LinkedIn/Apple hâlâ **BEKLİYOR** (düğmeler "Yakında" gösteriyor, ayrı geliştirici hesabı/kurulum gerektiriyor).
- [x] ~~Başarılı kayıt sonrası otomatik giriş yapılır ve ana sayfaya yönlendirilir~~ → **DEĞİŞTİRİLDİ:** kayıt sonrası otomatik giriş yapılmaz, kullanıcı `/giris` ekranına yönlendirilip elle giriş yapar. Bilinçli ürün kararı (Berzan) — gerekçe ve kodun yeri `CLAUDE.md` → Alınan Kararlar / US-001 sapması.

**US-002 — Giriş yapma**
> **Kullanıcı olarak**, e-posta/telefon + şifre ile **veya** sosyal hesapla giriş yapabilmek **istiyorum**.

**Kabul kriterleri:**
- [x] Hatalı bilgi girişinde genel bir hata mesajı gösterilir (hangi alanın yanlış olduğu belirtilmez — güvenlik): *"E-posta veya şifre hatalı"*
- [x] "Beni Hatırla" işaretlenirse oturum süresi uzatılır — *işaretli: 30 gün, işaretsiz: 1 gün*
- [x] "Şifremi Unuttum" akışı e-posta ile sıfırlama linki gönderir — *15 dk geçerli, tek amaçlı JWT; Mailtrap üzerinden*
- [x] Başarılı giriş sonrası JWT token alınır, ana sayfaya yönlendirilir — *token `flutter_secure_storage`'da saklanır, uygulama yeniden açıldığında oturum sürer*
- [ ] Sosyal hesapla giriş — **KISMEN**: Google hazır ama canlı doğrulanmadı, bkz. US-001'deki not. LinkedIn/Apple **BEKLİYOR**.

---

### Epic 2 — Ana Sayfa

**US-003 — Ana sayfa içeriklerini görüntüleme**
> **Kullanıcı olarak**, giriş yaptıktan sonra bölgeyle ilgili öne çıkan içerikleri tek ekranda görebilmek **istiyorum**.

**Kabul kriterleri:**
- [x] Üstte otomatik kayan banner (en az 3 görsel) gösterilir, API'den beslenir — *`GET /banners` uçtan uca bağlı; 2 sn'de bir kayan carousel + nokta göstergesi; `linkUrl` doluysa tıklanabilir (sadece http/https)*
- [x] Hızlı Erişim bölümünde en az 8 modül ikonu görünür (Firmalar, Navigasyon, İş İlanları, İkinci El Pazar, Cookzone, Palet Tesisi, Acil Durum, Duyurular) — *`hizli_erisim_kurallari.dart` → `hizliErisimSirasi`, tam 8 modül; hangisinin gerçek rotaya gittiği (`aktif`) ayrı bir kural*
- [x] Öne Çıkanlar bölümü en güncel 4 duyuru/haberi tarih + başlık ile listeler — *`OneCikanlarBolumu`, `GET /duyurular`'dan gelen listenin ilk 4'ü (05.08.2026)*
- [x] İş Ortakları bölümü sponsor logolarını listeler — *`IsOrtaklariBolumu`, `GET /is-ortaklari`'ya bağlı*
- [x] Tüm bölümlerde "Tümünü Gör" linki ilgili tam listeye yönlendirir — *Öne Çıkanlar → `/duyurular`, İş Ortakları → `/is-ortaklari`*

---

### Epic 3 — Firmalar

**US-004 — Firma listesini görüntüleme**
> **Kullanıcı olarak**, bölgedeki firmaları arayıp bulabilmek **istiyorum**.

**Kabul kriterleri:**
- [x] Firma adına göre arama yapılabilir — *`firmalar_ekrani.dart` → `_AramaKutusu`, debounce'lu, `GET /firmalar?arama=...`*
- [x] Sektöre göre filtrelenebilir — *`_SektorFiltreSatiri`, `GET /firmalar?sektor=...`*
- [x] Firma kartına tıklandığında detay sayfası açılır (adres, telefon, e-posta, sektör, logo) — *`/firmalar/:id`, deep-link güvenli (listeden veri taşınmaz, ID ile yeniden çekilir)*
- [x] Girişsiz kullanıcı da firmaları görebilir (katalog modeli, 05.08.2026) — *`FirmaController`'da class-level guard kaldırıldı, sadece yazma uçları (`POST`, `onayla`, `onay-bekleyenler`) korumalı; bkz. `docs/YENI-MODUL-REHBERI.md` "Okuma AÇIK, yazma KORUMALI"*

---

### Epic 4 — Duyurular

**US-005 — Duyuru listesi ve detayı**
> **Kullanıcı olarak**, bölge yönetiminden gelen duyuruları okuyabilmek **istiyorum**.

**Kabul kriterleri:**
- [x] Duyurular tarihe göre (en yeni üstte) listelenir — *`prisma-duyuru.repository.ts` → `orderBy: { yayinTarihi: 'desc' }`*
- [x] Duyuru kartına tıklandığında tam içerik görüntülenir — *`/duyurular/:id`, deep-link güvenli*
- [x] Sadece yetkili rol yeni duyuru oluşturabilir — *`YetkiGuard` + `@Yetki(DUYURU_YONET)`; DEĞİŞTİRİLDİ: "sadece Admin" değil, `rol_yetki` tablosuyla rol bazlı yetki (ileride başka bir role de aynı yetki tanımlanabilir, kod değişikliği gerekmez). Düzenleme/silme uçları henüz yazılmadı, sadece oluşturma var.*
- [x] Başlık/içeriğe göre arama yapılabilir (dokümanda yoktu, sonradan eklendi 05.08.2026) — *`duyurular_ekrani.dart` → `_AramaKutusu`, client-side filtre*
- [x] Kategoriye göre filtrelenebilir (dokümanda yoktu, sonradan eklendi) — *`_KategoriAcilirMenusu`*
- [x] Girişsiz kullanıcı da duyuruları görebilir (katalog modeli) — *`DuyuruController`'da `GET` uçlarında guard yok, sadece `POST` korumalı*

---

### Epic 5 — İş İlanları *(Faz 2)*

**US-006 — İş ilanı görüntüleme ve başvuru**
> **Kullanıcı olarak**, bölgedeki açık pozisyonları görüp başvurabilmek **istiyorum**.

**Kabul kriterleri:**
- [ ] İlan listesi firma adı, pozisyon, konum ve tarih gösterir
- [ ] Sadece **onaylı** firma hesapları ilan yayınlayabilir (Admin onayı gerekir)
- [ ] Başvuru yapıldığında ilgili firma yetkilisine bildirim/kayıt düşer

---

### Epic 6 — İkinci El Pazar *(Faz 2)*

**US-007 — İkinci el ilanı verme**
> **Kullanıcı olarak**, kullanmadığım eşyaları bölge içindeki diğer kullanıcılara satabilmek **istiyorum**.

**Kabul kriterleri:**
- [ ] İlan vermek için kullanıcının doğrulanmış (e-posta onaylı) hesabı olması zorunludur
- [ ] İlan; başlık, açıklama, fiyat, kategori, en az 1 fotoğraf içermelidir
- [ ] Satılan ilan "Satıldı" olarak işaretlenebilir, listeden otomatik gizlenmez ama etiketlenir

---

### Epic 7 — Acil Durum *(Faz 3)*

**US-008 — Acil durum bildirimi**
> **Kullanıcı olarak**, acil bir durumda tek dokunuşla bölge yönetimine bildirim gönderebilmek **istiyorum**.

**Kabul kriterleri:**
- [ ] Bildirim türü seçilir (Yangın, Kaza, Sağlık, Diğer)
- [ ] Konum bilgisi otomatik eklenir (kullanıcı izin verdiyse GPS, vermediyse manuel firma/bina seçimi)
- [ ] Gönderilen bildirim Admin panelinde anlık listelenir
- [ ] Bildirim türü ve konum **zorunlu** alanlardır, boş gönderilemez

---

### Epic 8 — Cookzone *(Faz 3)*

**US-009 — Menü görüntüleme ve sipariş**
> **Kullanıcı olarak**, bölge içindeki yemek noktalarının menüsünü görüp sipariş verebilmek **istiyorum**.

**Kabul kriterleri:**
- [ ] Menü öğeleri kategori bazlı listelenir (ör. ana yemek, içecek)
- [ ] Sipariş oluşturulduğunda durum takibi yapılabilir (Alındı → Hazırlanıyor → Hazır)
- [ ] Ödeme entegrasyonu bu fazda **kapsam dışıdır** — sipariş "kapıda ödeme/firma hesabına yansıtma" varsayımıyla ilerler

---

### Epic 9 — Bölge İçi Navigasyon *(Faz 2)*

**US-010 — Harita üzerinde konum bulma**
> **Kullanıcı olarak**, bölge içinde bir firmayı/binayı haritada bulabilmek **istiyorum**.

**Kabul kriterleri:**
- [ ] Harita üzerinde firma/bina noktaları işaretli görünür
- [ ] Nokta seçildiğinde firma bilgisi kartı açılır
- [ ] Kullanıcının mevcut konumundan seçilen noktaya yön tarifi gösterilir (temel seviye)

---

## 6. İş Kuralları (Özet — detayları `teknikPlan.md`'de)

| # | Kural |
|---|-------|
| BR-1 | Firma hesapları Admin onayı olmadan aktif olamaz |
| BR-2 | İş ilanı yalnızca onaylı Firma Yetkilisi hesabından yayınlanabilir |
| BR-3 | İkinci el ilanı vermek için e-posta doğrulaması zorunludur |
| BR-4 | Duyuru oluşturma/düzenleme/silme yalnızca Admin rolüne açıktır |
| BR-5 | Acil durum bildiriminde tür ve konum alanları zorunludur |
| BR-6 | Silinen/pasif firmaların ilanları otomatik olarak "pasif" durumuna alınır |
| BR-7 | Kullanıcı e-posta/telefon alanı sistemde benzersiz (unique) olmalıdır |

---

## 7. Teslimatlar (Deliverables)

| # | Teslimat | Faz | Zorunlu |
|---|----------|-----|---------|
| D1 | Git repository (mobil + backend ayrı veya monorepo) | 0 | ✓ |
| D2 | README — kurulum ve çalıştırma adımları | 0 | ✓ |
| D3 | Prisma migration + seed script | 0 | ✓ |
| D4 | Swagger dokümantasyonu | 1 | ✓ |
| D5 | Backend API — Faz 1 modülleri (Auth, Ana Sayfa, Firmalar, Duyurular, Profil) | 1 | ✓ |
| D6 | Flutter uygulaması — Faz 1 ekranları (iOS/Android/Web) | 1 | ✓ |
| D7 | Backend + Frontend — Faz 2 modülleri (İş İlanları, İkinci El Pazar, Navigasyon) | 2 | |
| D8 | Backend + Frontend — Faz 3 modülleri (Cookzone, Palet Tesisi, Acil Durum) | 3 | |
| D9 | Unit test projesi (min. iş kuralı testleri) | 1+ | ✓ |
| D10 | docker-compose.yml (PostgreSQL + API) | 0 | ✓ |

---

## 8. Kabul Kriterleri — Faz "Tamam" Sayılır

Her faz, kendi kapsamındaki User Story'lerin kabul kriterlerinin tamamı karşılandığında tamamlanmış sayılır:

- [ ] İlgili fazın tüm User Story'leri kabul kriterlerini karşılar
- [ ] İlgili iş kuralları backend'de test edilmiştir
- [ ] Swagger'da tüm endpoint'ler dokümante ve çalışır durumdadır
- [ ] README ile sıfırdan kurulum yapılabiliyor
- [ ] Git geçmişi anlamlı commit'ler içeriyor
- [ ] Mentor/bölge yönetimi ile demo yapılmış ve onay alınmıştır

---

## 9. Sözlük (Glossary)

| Terim | Açıklama |
|-------|----------|
| Bölge | Avrupa Serbest Bölgesi (platformun hizmet verdiği fiziksel alan) |
| Firma | Bölgede faaliyet gösteren, platformda kayıtlı işletme |
| Cookzone | Bölge içi yemek/kafeterya sipariş modülü |
| Carousel | Ana sayfada otomatik kayan görsel/banner alanı |
| Modüler Monolith | Tek kod tabanında, net sınırlarla ayrılmış modüllerden oluşan backend mimarisi |
| JWT | Kullanıcı oturumunu doğrulamak için kullanılan token standardı |
| DTO | Data Transfer Object — API request/response modeli |

---

## 10. Revizyon Geçmişi

| Versiyon | Tarih | Değişiklik |
|----------|-------|------------|
| 1.0 | 21.07.2026 | İlk taslak — mockup ve fikir alışverişi sonrası oluşturuldu |
| 1.1 | 27.07.2026 | Frontend kararı React Native/Expo → **Flutter (Dart)** (mentör talimatı, zorunlu). Bölüm 1 ve C1 kısıtı güncellendi |
| 1.2 | 28.07.2026 | Epic 1 (US-001/US-002) ve US-003'ün banner maddesi **gerçekleşen duruma göre işaretlendi**. US-001'in "kayıt sonrası otomatik giriş" kriteri bilinçli olarak değiştirildi (kullanıcı `/giris`'e yönlendiriliyor). Sosyal giriş "BEKLİYOR" olarak netleştirildi (Adım 4b) |
| 1.3 | 05.08.2026 | Epic 2/3/4'ün (Ana Sayfa, Firmalar, Duyurular) kabul kriterleri **gerçekleşen duruma göre işaretlendi** — kod çoktan yazılmıştı, doküman geride kalmıştı. Google ile giriş uçtan uca eklendi (LinkedIn/Apple hâlâ bekliyor). Firmalar/Duyurular okuma uçları girişsiz erişime açıldı ("katalog modeli" — bkz. `docs/YENI-MODUL-REHBERI.md`). Duyurular'a arama/kategori filtresi eklendi (dokümanda hiç yoktu). Bölüm 8'deki "Faz Tamam" kriterlerinden ikisi hâlâ açık: backend iş kuralı testleri (bu revizyonla `auth.service`/`firma.service`/`firma.entity` için eklendi, diğer modüller için henüz yok) ve mentor/bölge yönetimi demo+onayı (insan onayı gerektirir, otomatikleştirilemez) |

---

*Bu doküman, `teknikPlan.md` ve `izlence-typescript-nestjs(1).md` ile birlikte kullanılmalıdır. Yeni modül yazarken uygulama tarifi için `YENI-MODUL-REHBERI.md`.*
