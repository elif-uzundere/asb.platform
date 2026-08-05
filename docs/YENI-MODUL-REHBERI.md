# Yeni Modül Rehberi — Neyi Nereye Yazıyoruz?

> **Bu doküman ne işe yarar:** Yeni bir modül (duyuru, firma, iş ilanları…) açarken
> hangi dosyayı hangi klasöre yazacağını, hangi sırayla ilerleyeceğini ve neyi
> nereye YAZMAYACAĞINI gösterir. Auth + Banner modülleri bu şablona göre yazıldı;
> yeni modüller de aynı şablonu takip edecek.
>
> Sabit mimari kuralları → `CLAUDE.md`. Bu dosya o kuralların **uygulama tarifi**.

---

## 0. Tek Cümlelik Kural

**Her katman sadece bir soruyu cevaplar.** Bir dosyaya bir şey yazmadan önce
"bu hangi sorunun cevabı?" diye sor:

| Soru | Katman | Örnek |
|------|--------|-------|
| "Veri nereden geliyor?" | `data` | HTTP çağrısı, dosya okuma, url açma |
| "Kural ne diyor?" | `domain` | "şifre 8 karakter olmalı", "bu banner tıklanabilir mi" |
| "Ekranda ne oluyor?" | `presentation` | yükleniyor mu, hangi dialog açık, hangi metin |

Bir dosya iki soruyu birden cevaplıyorsa yanlış yerdedir.

---

## 1. Mimarinin Şekli — İki Taraf, Aynı Fikir

Backend (NestJS) ve frontend (Flutter) **aynı katmanlama fikrini** kullanıyor,
sadece isimler farklı:

```
        BACKEND (NestJS)                    FRONTEND (Flutter)
  ┌───────────────────────────┐      ┌───────────────────────────┐
  │ adapters/web              │      │ presentation/ekranlar     │  ← dış dünya
  │   Controller, DTO         │      │   Widget'lar              │
  ├───────────────────────────┤      ├───────────────────────────┤
  │ application               │      │ presentation/durum        │  ← akış/orkestrasyon
  │   Service (akış)          │      │   Notifier (Riverpod)     │
  ├───────────────────────────┤      ├───────────────────────────┤
  │ domain                    │      │ domain                    │  ← saf kurallar
  │   Entity, VO, Port        │      │   saf fonksiyonlar        │
  ├───────────────────────────┤      ├───────────────────────────┤
  │ adapters/persistence      │      │ data                      │  ← altyapı
  │   Prisma repository       │      │   dio, url_launcher       │
  └───────────────────────────┘      └───────────────────────────┘
```

**Ortak ilke:** Ortadaki iki katman (`domain`, `application`/`durum`) framework
bilmez. `domain` içinde `import 'package:flutter/...'` veya `@Injectable()`
görürsen **yanlıştır**. Böylece iş kuralını test etmek için ne sunucu ne ekran
gerekir — saf fonksiyon çağırıp sonuca bakarsın.

---

## 2. Backend — Yeni Modül Açma

### 2.1 Kaç katman?

| Modül tipi | Katman | Örnekler |
|---|---|---|
| **Basit** (CRUD, karmaşık kural yok) | `domain` + `adapters` | `duyuru`, `banner`, `is-ortaklari`, `harita`, `palet-tesisi` |
| **Karmaşık** (çok adımlı akış, durum makinesi) | `domain` + `application` + `adapters` | `auth`, `firma`, `is-ilanlari`, `ikinci-el-pazar`, `cookzone`, `acil-durum` |

> Basit modüle `application` ekleme — boş bir servis katmanı sadece gürültü (KISS).
> Karmaşıklaşırsa o zaman eklersin.

### 2.2 Dosya ağacı (örnek: `duyuru`, 2 katmanlı)

```
packages/backend/src/modules/duyuru/
├── domain/
│   ├── duyuru.entity.ts          # Saf TS class — @Injectable YOK
│   ├── duyuru.repository.ts      # Interface (port) — Prisma bilmez
│   ├── duyuru.exceptions.ts      # DuyuruBulunamadiException gibi
│   └── index.ts                  # Dışarıya tek kapı: export * from '...'
├── adapters/
│   ├── web/
│   │   ├── duyuru.controller.ts  # @Controller('duyurular')
│   │   ├── duyuru-olustur.dto.ts # class-validator + TÜRKÇE message
│   │   └── index.ts
│   ├── persistence/
│   │   ├── prisma-duyuru.repository.ts   # domain'deki interface'i implement eder
│   │   └── index.ts
│   └── public/                   # SADECE başka modül veri isteyecekse
│       └── duyuru-sorgulama.port.ts
├── duyuru.tokens.ts              # DI token'ları (Symbol/string sabitleri)
└── duyuru.module.ts              # Nest wiring — SADECE burada @Module/useFactory
```

3 katmanlıysa araya `application/duyuru.service.ts` girer ve controller
repository'yi değil **servisi** çağırır.

### 2.3 Sıra (Modül Geliştirme Protokolü)

1. **Sözleşme:** `packages/shared-types/src/duyuru.types.ts` → `DuyuruResponse`,
   `DuyuruOlusturRequest`. İş mantığı yok, sadece şekil. **Küçük PR, hızlı merge.**
2. **Domain:** entity + repository *interface*'i + exception'lar.
3. **Persistence:** Prisma repository — interface'i implement eder.
4. **Web:** DTO + controller.
5. **Wiring:** `duyuru.module.ts` + `app.module.ts`'e ekle.

### 2.4 Backend'de mutlaka uyulacaklar

- **Response zarfı:** Controller **her zaman** `ApiResponseDto.ok(veri)` döner.
  Çıplak dizi/nesne dönme — Flutter tarafı tek bir şekil bekliyor.
  ```ts
  @Get()
  async duyurulariGetir(): Promise<ApiResponseDto<DuyuruResponse[]>> {
    return ApiResponseDto.ok(await this.repo.hepsiniGetir());
  }
  ```
- **Validasyon:** Gövde alan DTO'ların hepsinde class-validator kuralı olacak ve
  **her decorator'a Türkçe `message` yazılacak**:
  ```ts
  @IsString({ message: 'Başlık geçersiz' })
  @MinLength(3, { message: 'Başlık en az 3 karakter olmalı' })
  baslik!: string;
  ```
  Sebep: global `ValidationPipe` açık ve Flutter `error.message`'ı kullanıcıya
  **olduğu gibi** gösteriyor. Türkçe yazmazsan kullanıcı İngilizce hata görür.
- **Hata fırlatma:** `domain`'de kendi exception'ını fırlat, `adapters/web`'de
  `HttpException`'a çevir. `GlobalExceptionFilter` zarfa sarmayı üstlenir.
- **Modüller arası erişim:** Başka modülün `domain`/`persistence` klasörünü
  **asla** import etme — sadece `adapters/public/*.port.ts`.
- **`schema.prisma` ortak:** kolon/tablo gerekiyorsa küçük ayrı PR, sessizce değil.
- **Okuma AÇIK, yazma KORUMALI (katalog/Trendyol modeli — 05.08.2026, Berzan'ın
  kararı):** Platform ASB'nin kendi web sitesi gibi davranıyor — bir ziyaretçi
  giriş yapmadan **her şeyi görebilmeli** (firma listesi/detayı, duyurular,
  iş ilanları, Cookzone menüsü — hangi modül olursa olsun), ama **hiçbir şeyi
  değiştirememeli** (ilan veremez, başvuru yapamaz, destek talebi açamaz,
  favori ekleyemez). Bu yüzden:
  - `@UseGuards(JwtAuthGuard, ...)` **controller/sınıf seviyesine ASLA
    konmaz** sırf "modül kapalı olsun" diye — o zaman GET'ler de kilitlenir
    (bu hata bir kere yapıldı: `FirmaController`, düzeltildi, bkz. git geçmişi
    05.08.2026). Guard **sadece** state değiştiren metotlara
    (`@Post`/`@Put`/`@Patch`/`@Delete`) veya gerçekten "sadece admin görsün"
    olan tekil `@Get`'lere (ör. onay kuyruğu) tek tek yazılır.
  - İstisna: bir kaynağın TAMAMI kullanıcıya özel/kişiselse (ör.
    `destek-talepleri` — "sadece KENDİ taleplerim") class-level guard
    doğrudur, çünkü orada GET de zaten kişiye özel, herkese açık değil.
  - Yeni bir modül yazarken kendine sor: "Bunu girişsiz bir ziyaretçi
    görebilmeli mi?" Cevap evetse (çoğu zaman evettir) GET'e guard **koyma**.

---

## 3. Flutter — Yeni Modül Açma

### 3.1 Dosya ağacı (örnek: `duyurular`)

```
packages/app/lib/features/duyurular/
├── data/
│   └── duyuru_api.dart           # dio çağrıları — apiIstegi() kullanır
├── domain/
│   └── duyuru_kurallari.dart     # saf kurallar; Flutter import'u YOK
└── presentation/
    ├── durum/
    │   └── duyuru_notifier.dart  # Riverpod provider/notifier
    ├── ekranlar/
    │   └── duyurular_ekrani.dart # SADECE görünüm
    └── widgets/
        └── duyuru_karti.dart
```

Model (`DuyuruResponse`) **feature'a değil**, `lib/core/models/duyuru_modelleri.dart`
içine yazılır — çünkü `shared-types`'ın Dart aynası orada duruyor ve birden fazla
feature aynı modeli kullanabiliyor.

### 3.2 `data/` — API çağrısı

Zarf çözme ve hata çevirme **ortak**; tekrar yazma:

```dart
import '../../../core/network/api_istegi.dart';

class DuyuruApi {
  const DuyuruApi(this._dio);
  final Dio _dio;

  Future<List<DuyuruResponse>> duyurulariGetir() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/duyurular'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(DuyuruResponse.jsondan)
            .toList(),
        yedekMesaj: 'Duyurular yüklenemedi.',
      );
}

final duyuruApiProvider =
    Provider<DuyuruApi>((ref) => DuyuruApi(ref.watch(apiClientProvider)));
```

`apiIstegi` senin için şunları yapar: `success` kontrolü, backend'in Türkçe
`error.message`'ını `ApiHata` olarak fırlatma, ağ hatasını çevirme.

### 3.3 `presentation/durum/` — iki kalıp

**(a) Veri okuma (liste/detay) → `FutureProvider`:**

```dart
final duyurularProvider = FutureProvider<List<DuyuruResponse>>(
  (ref) => ref.watch(duyuruApiProvider).duyurulariGetir(),
);
```
Ekranda `.when(loading:, error:, data:)` ile kullanılır.

**(b) Form gönderme (yaz/güncelle/sil) → `FormNotifier`:**

```dart
class DuyuruOlusturNotifier extends FormNotifier {
  DuyuruOlusturNotifier(this._api);
  final DuyuruApi _api;

  Future<void> gonder({required String baslik, required String icerik}) =>
      calistir(() => _api.duyuruOlustur(
            DuyuruOlusturRequest(
              baslik: girdiyiTemizle(baslik),
              icerik: girdiyiTemizle(icerik),
            ),
          ));
}

final duyuruOlusturNotifierProvider =
    StateNotifierProvider.autoDispose<DuyuruOlusturNotifier, IslemDurumu>(
  (ref) => DuyuruOlusturNotifier(ref.watch(duyuruApiProvider)),
);
```

`FormNotifier`'dan bedava gelenler: `yükleniyor` durumu, `ApiHata` yakalama,
**çift tıklama koruması**. Bunları ekranda tekrar yazma.

### 3.4 `presentation/ekranlar/` — sadece görünüm

```dart
@override
Widget build(BuildContext context) {
  ref.listen<IslemDurumu>(duyuruOlusturNotifierProvider, (_, sonraki) {
    islemGeriBildirimi(
      context,
      sonraki,
      hataBasligi: 'Duyuru oluşturulamadı',
      basariBasligi: 'Kaydedildi',
      basariMesaji: 'Duyuru yayınlandı.',
      basariSonrasi: () => context.go('/duyurular'),
      sifirla: ref.read(duyuruOlusturNotifierProvider.notifier).sifirla,
    );
  });

  final yukleniyor = ref.watch(duyuruOlusturNotifierProvider) is IslemSuruyor;
  // ... sadece widget ağacı
}
```

### 3.5 Ekranda OLMAMASI gerekenler (kod incelemesinde bunlara bakılıyor)

| ❌ Yanlış (widget içinde) | ✅ Doğru yer |
|---|---|
| `dio.get(...)`, `ref.read(xApiProvider).y()` | `data/` + notifier |
| `launchUrl`, dosya okuma, platform çağrısı | `data/` |
| `try { } on ApiHata catch { }` | `FormNotifier.calistir` |
| `bool _yukleniyor = false; setState(...)` | `IslemDurumu` |
| `metin.trim()` | `domain` (`girdiyiTemizle`) |
| `if (token != null && token.isNotEmpty)` | `domain` (saf kural fonksiyonu) |
| `'Hata: ' + kod` ile mesaj üretme | backend `error.message`'ı olduğu gibi göster |

Widget'ta kalması **doğru** olanlar: `TextEditingController`, `setState` ile
şifre göster/gizle gibi salt görsel durumlar, renk/boyut/metin, `context.go(...)`.

### 3.6 Hazır parçalar (yeniden yazma)

| Ne lazım | Nereden |
|---|---|
| API çağrısı + zarf çözme | `core/network/api_istegi.dart` → `apiIstegi()` |
| Hata tipi | `core/network/api_hata.dart` → `ApiHata` |
| Form durumu | `core/durum/islem_durumu.dart` → `FormNotifier`, `IslemDurumu` |
| Dialog + yönlendirme | `core/widgets/islem_geri_bildirimi.dart` |
| Girdi kutusu / buton / şifre gözü | `core/widgets/form_ogeleri.dart` |
| Renkler | `core/theme/renkler.dart` → `Renkler.lacivert` … |
| Token'lı HTTP istemcisi | `core/network/api_client.dart` (interceptor hazır) |
| Yeni sekme/rota | `core/router/yonlendirici.dart` + `sekme_kabugu.dart` |

---

## 4. Uçtan Uca Sözleşme Zinciri

Bir alan eklerken **üç yeri birden** güncellemen gerekir:

```
1. packages/shared-types/src/duyuru.types.ts     (TS — tek kaynak)
        │
        ├──► 2. backend DTO + entity            (aynı PR)
        │
        └──► 3. packages/app/lib/core/models/duyuru_modelleri.dart   (aynı PR)
                 Dart bu TS paketini import EDEMEZ → elle ayna tutuyoruz.
                 Dosyanın başına "Kaynak: packages/shared-types/src/..." yaz.
```

> **Neden elle?** Dart, TypeScript paketini import edemiyor. Şu an ayna yüzeyi
> küçük (auth + banner), elle tutmak codegen kurmaktan ucuz. Modül sayısı artınca
> Swagger/OpenAPI'den Dart model üretimine geçmeyi ayrıca konuşacağız
> (bkz. `CLAUDE.md` → Alınan Kararlar, 27.07.2026).

**Ayna bozulmasın diye:** her model için `packages/app/test/core/` altına küçük
bir JSON çözümleme testi yaz (örnek: `auth_modelleri_test.dart`).

---

## 5. Bitirme Kontrol Listesi

Modülü "bitti" demeden önce:

**Backend**
- [ ] `shared-types`'ta DTO tanımlı
- [ ] Controller `ApiResponseDto.ok(...)` dönüyor
- [ ] Gövde alan her DTO'da class-validator + **Türkçe** `message`
- [ ] `domain`'de NestJS decorator'ı yok
- [ ] Başka modüle erişim sadece `adapters/public/` üzerinden
- [ ] `npm run lint` ve `npm run build` temiz

**Flutter**
- [ ] `data/` + `domain/` + `presentation/` klasörleri var
- [ ] Widget içinde API çağrısı / try-catch / trim / iş kuralı **yok**
- [ ] Form akışları `FormNotifier`'dan türüyor
- [ ] Model `core/models/` altında + başında "Kaynak:" yorumu
- [ ] Domain kuralları için test yazıldı (`test/features/<modul>/`)
- [ ] `flutter analyze` temiz, `flutter test` yeşil

**Ortak**
- [ ] Uçtan uca elle denendi (backend ayakta + `flutter run -d chrome`)
- [ ] Mimari kuralla çelişen bir karar verildiyse `CLAUDE.md` → "Alınan Kararlar"a
      tarihli madde olarak yazıldı

---

## 6. Referans: Şu An Yazılmış Modüller

Şablonu somut görmek için bunları oku:

| Modül | Backend | Flutter | Ne öğretir |
|---|---|---|---|
| **banner** | `modules/banner/` (2 katman) | `features/ana_sayfa/` | En sade uçtan uca akış: GET → liste → widget |
| **auth** | `modules/auth/` (3 katman) | `features/auth/` | Form akışları, oturum durumu, kalıcı token, domain kuralları |

Yeni modüle başlarken **banner**'ı kopyala (basitse), **auth**'u kopyala (form/akış varsa).
