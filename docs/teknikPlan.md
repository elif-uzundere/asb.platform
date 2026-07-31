# Teknik Plan — ASB Platform
## Flutter + NestJS + PostgreSQL Mimarisi

> **Not (21.07.2026 güncellemesi):** Frontend kararı Flutter'dan **React Native**'e değişti; backend **TypeScript (NestJS)** olarak kesinleşti (dil birliği avantajı için). Bu dosyadaki veri modeli (Bölüm 4) ve API listesi (Bölüm 6) dilden bağımsız olduğu için aynen geçerli; frontend'e özel bölümler (2, 7) güncellendi. Katmanlı backend mimarisinin (modül-önce ayrım, SOLID/KISS/DRY, Nielsen ilkeleri) detaylı ve güncel hali için `izlence-typescript-nestjs.md`'ye bakın — bu doküman artık öncelikle **veri modeli ve API referansı** olarak kullanılıyor.
>
> **Not (27.07.2026 güncellemesi):** Frontend kararı bu kez **React Native'den tekrar Flutter'a** döndü — mentör talimatıyla, zorunlu. Backend TypeScript (NestJS) değişmedi, "dil birliği" argümanı (satır 31) artık geçerli değil — bkz. `docs/CLAUDE.md` Alınan Kararlar. Bölüm 1, 2 ve 7'deki "React Native" ifadeleri Flutter'ın karşılığı olarak okunmalı; veri modeli (Bölüm 4) ve API listesi (Bölüm 6) yine dilden bağımsız, değişmedi.

> **İlgili dokümanlar:** `isterler.md` (ne), `izlence-typescript-nestjs.md` (mimari, kurulum ve adım planı)

---

## 1. Genel Mimari

```
┌───────────────────────────┐        HTTPS/JSON        ┌───────────────────────────┐
│   Flutter Uygulaması      │  ◄──────────────────────► │   NestJS Backend API      │
│   iOS / Android / Web     │                            │   (TypeScript)            │
│   (tek kod tabanı)        │                            │                            │
└───────────────────────────┘                            │  Controller → Service      │
                                                          │       ↓                    │
                                                          │  Repository (Prisma ORM)   │
                                                          └──────────┬─────────────────┘
                                                                     │
                                                          ┌──────────▼─────────────────┐
                                                          │      PostgreSQL 16         │
                                                          └────────────────────────────┘
```

### Neden bu mimari? (kısa gerekçe)

| Karar | Gerekçe |
|-------|---------|
| Flutter (Dart) | iOS/Android/Web için tek kod tabanı; Flutter Web resmi ve olgun bir hedef (React Native Web'in aksine). Dil birliği artık yok (backend TS, frontend Dart) — bkz. Not (27.07.2026) |
| NestJS | ASP.NET Core'a kavramsal olarak yakın (Decorator, DI, Module) — geçmişte .NET görmüş biri kolay adapte olur |
| Modüler Monolith | 10 yıl vadeli proje için mikroservisin karmaşıklığı gereksiz; modüller net ayrılırsa ileride bölünebilir |
| PostgreSQL | Veri yapısı ilişkisel (firma-kullanıcı-ilan bağları), migration ve tutarlılık kritik |
| Prisma (ORM) | NestJS ile en yaygın kombinasyon, migration yönetimi EF Core'a kavramsal olarak benzer |

---

## 2. Teknoloji Yığını (Stack)

| Katman | Teknoloji | Not |
|--------|-----------|-----|
| Mobil + Web Frontend | **Flutter** (Dart) | State management: Riverpod, routing: go_router, HTTP: dio, token saklama: flutter_secure_storage (27.07.2026 kararı) |
| Backend | **NestJS** (TypeScript) | Node.js 20 LTS üzerinde |
| ORM | **Prisma** | Migration + type-safe query |
| Veritabanı | **PostgreSQL 16** | Docker container ile |
| API Dokümantasyon | **Swagger (nestjs/swagger)** | Otomatik OpenAPI üretimi |
| Kimlik Doğrulama | **JWT (Passport.js)** + OAuth (Google/Apple/LinkedIn) | Faz 1 sonunda |
| Test | **Jest** (backend), **flutter_test** (frontend) | |
| Container | **Docker + Docker Compose** | Prod benzeri ortam |
| CI | **GitHub Actions** | Build + test pipeline |
| Harita | **Google Maps SDK / flutter_map** | Navigasyon modülü için |

---

## 3. Git ve Çalışma Akışı

```
main            ← stabil, canlıya alınabilir kod
  └── develop   ← günlük/haftalık entegrasyon
        └── feature/auth
        └── feature/ana-sayfa
        └── feature/firmalar
        └── feature/is-ilanlari
        └── feature/ikinci-el-pazar
```

**Kurallar:**
- `main`'e doğrudan commit yok, PR ile merge
- Commit mesajları: `feat:`, `fix:`, `docs:`, `refactor:`, `test:` (Conventional Commits)
- Her modül kendi feature branch'inde geliştirilir

**Repo yapısı ve klasör detayları:** Artık `izlence-typescript-nestjs.md` Bölüm 2'de güncel — monorepo (`packages/backend`, `packages/shared-types` + Flutter için `packages/app`), her backend modülünün `domain/application/adapters` katmanlarına ayrıldığı yapı orada tanımlı. **Bu dosyada tekrarlanmıyor** (aynı bilginin iki yerde, birbirinden bağımsız güncellenmesi zamanla tutarsızlığa yol açar — tam da DRY'ın önlemeye çalıştığı şey). Katman sorumlulukları da aynı dosyanın Bölüm 1 ve 3'ünde (`domain` iş kuralı, `application` orkestrasyon, `adapters/web` HTTP, `adapters/persistence` veritabanı) tanımlı.

---

## 4. Veritabanı Şeması

### 4.1 Kullanıcı ve Firma

#### `kullanici`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| email | varchar(150) | unique |
| telefon | varchar(20) | unique, nullable |
| sifre_hash | varchar(255) | nullable (sosyal girişte boş olabilir) |
| ad | varchar(60) | |
| soyad | varchar(60) | |
| firma_id | uuid | FK → firma, nullable |
| rol | enum | `ziyaretci`, `firma_calisani`, `firma_yetkilisi`, `admin` |
| eposta_dogrulandi | boolean | default false |
| olusturma_tarihi | timestamp | |
| guncelleme_tarihi | timestamp | |

#### `firma`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| ad | varchar(150) | |
| logo_url | varchar(255) | nullable |
| sektor | varchar(80) | |
| adres | varchar(255) | |
| telefon | varchar(20) | nullable |
| eposta | varchar(150) | nullable |
| onay_durumu | enum | `beklemede`, `onaylandi`, `reddedildi` |
| aktif | boolean | default true |
| olusturma_tarihi | timestamp | |

### 4.2 Ana Sayfa İçerikleri

#### `banner`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| gorsel_url | varchar(255) | |
| link_url | varchar(255) | nullable |
| sira | int | görüntülenme sırası |
| aktif | boolean | |

#### `duyuru`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| baslik | varchar(200) | |
| icerik | text | |
| kategori | varchar(60) | nullable |
| yayin_tarihi | timestamp | |
| olusturan_admin_id | uuid | FK → kullanici |

#### `is_ortagi` (sponsor/iş ortağı)
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| ad | varchar(150) | |
| logo_url | varchar(255) | |
| kategori | varchar(80) | nullable |

### 4.3 İş İlanları *(Faz 2)*

#### `is_ilani`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| firma_id | uuid | FK → firma |
| baslik | varchar(150) | |
| aciklama | text | |
| konum | varchar(150) | nullable |
| yayin_tarihi | timestamp | |
| durum | enum | `aktif`, `kapali` |
| olusturan_kullanici_id | uuid | FK → kullanici (firma yetkilisi) |

#### `is_basvurusu`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| is_ilani_id | uuid | FK → is_ilani |
| kullanici_id | uuid | FK → kullanici |
| basvuru_tarihi | timestamp | |
| durum | enum | `beklemede`, `incelendi`, `reddedildi`, `kabul` |

### 4.4 İkinci El Pazar *(Faz 2)*

#### `ikinci_el_ilani`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| kullanici_id | uuid | FK → kullanici |
| baslik | varchar(150) | |
| aciklama | text | |
| fiyat | decimal(10,2) | |
| kategori | varchar(80) | |
| fotograf_urls | text[] | JSON/array olarak fotoğraf linkleri |
| durum | enum | `aktif`, `satildi`, `pasif` |
| olusturma_tarihi | timestamp | |

### 4.5 Bölge İçi Navigasyon *(Faz 2)*

#### `bolge_noktasi`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| ad | varchar(150) | |
| tur | enum | `firma`, `giris_cikis`, `ortak_alan`, `acil_nokta` |
| firma_id | uuid | FK → firma, nullable |
| enlem | decimal(9,6) | |
| boylam | decimal(9,6) | |

### 4.6 Cookzone *(Faz 3)*

#### `cookzone_isletme`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| ad | varchar(150) | |
| bolge_noktasi_id | uuid | FK → bolge_noktasi |

#### `cookzone_menu_ogesi`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| isletme_id | uuid | FK → cookzone_isletme |
| ad | varchar(150) | |
| aciklama | text | nullable |
| fiyat | decimal(8,2) | |
| kategori | varchar(60) | |
| aktif | boolean | |

#### `cookzone_siparis`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| kullanici_id | uuid | FK → kullanici |
| isletme_id | uuid | FK → cookzone_isletme |
| durum | enum | `alindi`, `hazirlaniyor`, `hazir`, `teslim_edildi` |
| toplam_tutar | decimal(10,2) | |
| olusturma_tarihi | timestamp | |

#### `cookzone_siparis_kalemi`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| siparis_id | uuid | FK → cookzone_siparis |
| menu_ogesi_id | uuid | FK → cookzone_menu_ogesi |
| adet | int | |

### 4.7 Acil Durum *(Faz 3)*

#### `acil_durum_bildirimi`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| kullanici_id | uuid | FK → kullanici |
| tur | enum | `yangin`, `kaza`, `saglik`, `diger` |
| enlem | decimal(9,6) | nullable |
| boylam | decimal(9,6) | nullable |
| bolge_noktasi_id | uuid | FK → bolge_noktasi, nullable (manuel konum seçimi) |
| aciklama | text | nullable |
| durum | enum | `yeni`, `inceleniyor`, `kapatildi` |
| olusturma_tarihi | timestamp | |

### 4.8 Palet Tesisi *(Faz 3)*

#### `palet_tesisi`
| Kolon | Tip | Not |
|-------|-----|-----|
| id | uuid | PK |
| kullanici_id | uuid | FK → kullanici (alıcı) |
| kargo_firmasi | varchar(100) | nullable |
| takip_no | varchar(100) | nullable |
| durum | enum | `beklemede`, `bolgede`, `teslim_edildi` |
| teslim_noktasi_id | uuid | FK → bolge_noktasi, nullable |
| olusturma_tarihi | timestamp | |

---

## 5. İş Kuralları (Backend Service Katmanında Uygulanacak)

| # | Kural | Uygulama Noktası |
|---|-------|-------------------|
| BR-1 | Yeni firma kaydı `onay_durumu = beklemede` ile başlar, admin onayı sonrası `onaylandi` olur | FirmalarService |
| BR-2 | `onay_durumu != onaylandi` olan firmalar iş ilanı yayınlayamaz | IsIlanlariService |
| BR-3 | İkinci el ilanı oluşturmak için `eposta_dogrulandi = true` şartı aranır | IkinciElPazarService |
| BR-4 | Duyuru CRUD işlemleri sadece `rol = admin` tarafından yapılabilir | DuyurularService + RolesGuard |
| BR-5 | Acil durum bildiriminde `tur` ve (`enlem+boylam` **veya** `bolge_noktasi_id`) zorunludur | AcilDurumService |
| BR-6 | Firma pasif/silinmiş duruma geçerse, o firmaya bağlı aktif iş ilanları otomatik `kapali` yapılır | FirmalarService (cascade) |
| BR-7 | `email` ve `telefon` alanları sistemde benzersizdir | Prisma `@unique` + Service kontrolü |
| BR-8 | İkinci el ilanı "satıldı" işaretlendiğinde silinmez, sadece durumu güncellenir | IkinciElPazarService |

---

## 6. REST API Endpoint'leri (Özet)

**Versiyonlama:** Tüm endpoint'ler `/api/v1/...` altında yayınlanır (NestJS'te `URI Versioning` — `app.enableVersioning({ type: VersioningType.URI, defaultVersion: '1' })`). İleride kırıcı bir değişiklik gerekirse (örn. mobil eski sürümlerin bozulmaması için) `/api/v2/...` paralel yayınlanır, `v1` bir süre daha desteklenmeye devam eder.

### Auth
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/oauth/google
POST   /api/v1/auth/oauth/apple
POST   /api/v1/auth/forgot-password
POST   /api/v1/auth/reset-password
GET    /api/v1/auth/me
```

### Ana Sayfa
```
GET    /api/v1/banners
GET    /api/v1/duyurular?limit=4
GET    /api/v1/is-ortaklari
```

### Firmalar
```
GET    /api/v1/firmalar?search=&sektor=
GET    /api/v1/firmalar/{id}
POST   /api/v1/firmalar              (admin — yeni firma tanımlama)
PUT    /api/v1/firmalar/{id}/onayla  (admin)
```

### Duyurular
```
GET    /api/v1/duyurular
GET    /api/v1/duyurular/{id}
POST   /api/v1/duyurular             (admin)
PUT    /api/v1/duyurular/{id}        (admin)
DELETE /api/v1/duyurular/{id}        (admin)
```

### İş İlanları *(Faz 2)*
```
GET    /api/v1/is-ilanlari?firmaId=&durum=
GET    /api/v1/is-ilanlari/{id}
POST   /api/v1/is-ilanlari                     (firma yetkilisi)
POST   /api/v1/is-ilanlari/{id}/basvur         (kullanıcı)
```

### İkinci El Pazar *(Faz 2)*
```
GET    /api/v1/ikinci-el-ilanlari?kategori=&search=
GET    /api/v1/ikinci-el-ilanlari/{id}
POST   /api/v1/ikinci-el-ilanlari
PUT    /api/v1/ikinci-el-ilanlari/{id}/durum   (satıldı işaretleme)
```

### Harita / Navigasyon *(Faz 2)*
```
GET    /api/v1/bolge-noktalari?tur=
GET    /api/v1/bolge-noktalari/{id}
```

### Cookzone *(Faz 3)*
```
GET    /api/v1/cookzone/isletmeler
GET    /api/v1/cookzone/isletmeler/{id}/menu
POST   /api/v1/cookzone/siparisler
GET    /api/v1/cookzone/siparisler/{id}
PUT    /api/v1/cookzone/siparisler/{id}/durum
```

### Acil Durum *(Faz 3)*
```
POST   /api/v1/acil-durum
GET    /api/v1/acil-durum              (admin — tüm bildirimler)
PUT    /api/v1/acil-durum/{id}/durum   (admin)
```

### Palet Tesisi *(Faz 3)*
```
GET    /api/v1/palet-tesisleri
POST   /api/v1/palet-tesisleri
PUT    /api/v1/palet-tesisleri/{id}/durum
```

### Response Zarfı — TÜM endpoint'ler için tek şekil

Kaynak: `packages/backend/src/shared/web/api-response.dto.ts`. Her controller
`ApiResponseDto.ok(...)` döner; çıplak dizi/nesne dönülmez. Hatalar
`GlobalExceptionFilter` tarafından aynı zarfa sarılır.

**Başarılı:**
```json
{ "success": true, "data": { "accessToken": "...", "kullanici": { } } }
```

`data` boş olabilir (ör. `POST /auth/sifremi-unuttum` → `"data": null`).

**Hatalı:**
```json
{
  "success": false,
  "error": { "code": "BAD_REQUEST", "message": "Şifre en az 8 karakter olmalı" }
}
```

**Kritik kural — `error.message` doğrudan kullanıcıya gösterilir.** Flutter tarafı
kod→metin eşleme tablosu tutmuyor, mesajı olduğu gibi ekrana basıyor. Bu yüzden
**her class-validator decorator'ına Türkçe `message` yazılmalıdır**:

```ts
@IsEmail({}, { message: 'Geçerli bir e-posta adresi girin' })
email!: string;
```

Türkçe mesaj yazılmazsa kullanıcı class-validator'ın İngilizce varsayılanını
("email must be an email") görür. Birden fazla kural birden ihlal edilirse
mesajlar virgülle birleştirilir.

Global `ValidationPipe` `whitelist: true` ile çalışır — DTO'da tanımlı olmayan
alanlar gövdeden **düşürülür** (ör. `"rol": "admin"` enjekte edilemez).

### HTTP Status Kod Beklentileri

| Durum | Kod |
|-------|-----|
| Başarılı okuma | 200 |
| Başarılı oluşturma | 201 |
| Başarılı güncelleme | 200 |
| Başarılı silme | 204 |
| Validasyon hatası | 400 |
| Yetkisiz erişim | 401 |
| Yasak (rol yetersiz) | 403 |
| Bulunamadı | 404 |
| Çakışma (duplicate) | 409 |

---

## 7. Flutter Uygulaması — Ekran Planı

Mockup'taki ekranlar temel alınarak — **go_router** ile `ShellRoute` (bottom tab) + üstte tam ekran auth rotaları.

| Ekran | Karşılık gelen API | Faz | Durum |
|-------|---------------------|-----|-------|
| Giriş / Kayıt | `/auth/register`, `/auth/login` | 1 | ✅ yazıldı |
| Şifremi Unuttum / Şifre Sıfırla | `/auth/sifremi-unuttum`, `/auth/sifre-sifirla` | 1 | ✅ yazıldı |
| Ana Sayfa (banner carousel) | `/banners` | 1 | ✅ yazıldı (uçtan uca bağlı) |
| Ana Sayfa (hızlı erişim + öne çıkanlar + iş ortakları) | `/duyurular`, `/is-ortaklari` | 1 | ⬜ placeholder metin |
| Profil | oturum durumundan (`/auth/me` henüz yok) | 1 | ✅ yazıldı |
| Firmalar listesi + detay | `/firmalar` | 1 | ⬜ boş placeholder |
| Duyurular listesi + detay | `/duyurular` | 1 | ⬜ boş placeholder |
| Harita / Navigasyon | `/bolge-noktalari` | 2 | ⬜ boş placeholder |
| İş İlanları listesi + detay + başvuru | `/is-ilanlari` | 2 | ⬜ |
| İkinci El Pazar listesi + ilan verme | `/ikinci-el-ilanlari` | 2 | ⬜ |
| Cookzone menü + sipariş | `/cookzone/*` | 3 | ⬜ |
| Acil Durum bildirimi | `/acil-durum` | 3 | ⬜ |
| Palet Tesisi takibi | `/palet-tesisleri` | 3 | ⬜ |

**Bottom Tab (mockuptaki gibi):** Ana Sayfa, Firmalar, Harita, Duyurular, Profil — `SekmeKabugu` (ShellRoute gövdesi).

**Rota koruması:** `yonlendirici.dart` içindeki `redirect` callback'i oturumsuz kullanıcıyı `/giris`'e yollar. Açık rotalar: `/giris`, `/kayit`, `/sifremi-unuttum`, `/sifre-sifirla`.

**Admin rotası bilerek kurulmadı** — AdminJS kararı netleşmedi (bkz. `CLAUDE.md`).

**Ekran yazarken:** klasör/katman tarifi ve kontrol listesi `docs/YENI-MODUL-REHBERI.md` Bölüm 3'te. Widget içinde API çağrısı/iş kuralı yazılmaz.

**Web notu:** Geliştirme hedefi Chrome (`flutter run -d chrome`). Flutter web **hash routing** kullanıyor (`/#/giris`) — e-posta/derin link üretirken bu format esas alınmalı. Harita ve fotoğraf yükleme gibi native yetenekler Adım 14'te (Web uyarlaması) ele alınacak.

---

## 8. Değerlendirme Kriterleri

| Ağırlık | Kriter |
|---------|--------|
| %25 | Mimari — modül ayrımı, DI, servis/controller sorumluluk ayrımı |
| %25 | İş kuralları — Bölüm 5'teki kuralların doğru uygulanması |
| %20 | API tasarımı — RESTful, DTO, hata yönetimi, Swagger |
| %15 | Flutter tarafı — ekranlar, state management, API entegrasyonu, web/native tutarlılığı |
| %10 | Git disiplini — anlamlı commit, branch, README |
| %5 | Test — en az temel unit testler |

---

*Hazırlayan: Stajyer — Kaynak: Mobil uygulama mockup'ı + fikir alışverişi*
*Son güncelleme: 21.07.2026*
