// Kaynak: packages/shared-types/src/is-ilanlari.types.ts
//
// packages/shared-types bir TypeScript paketi ve Dart'tan import edilemiyor;
// bu yüzden tipler burada EL İLE yansıtılıyor (manuel mirror, bkz.
// auth_modelleri.dart başındaki not).

/// TS: `export type IsIlaniDurumu = 'aktif' | 'kapali'`
enum IsIlaniDurumu {
  aktif('aktif'),
  kapali('kapali');

  const IsIlaniDurumu(this.deger);

  final String deger;

  static IsIlaniDurumu cozumle(String? deger) => IsIlaniDurumu.values.firstWhere(
        (durum) => durum.deger == deger,
        orElse: () => IsIlaniDurumu.kapali,
      );
}

/// TS: `export type IsBasvurusuDurumu = 'beklemede' | 'incelendi' | 'reddedildi' | 'kabul'`
enum IsBasvurusuDurumu {
  beklemede('beklemede'),
  incelendi('incelendi'),
  reddedildi('reddedildi'),
  kabul('kabul');

  const IsBasvurusuDurumu(this.deger);

  final String deger;

  static IsBasvurusuDurumu cozumle(String? deger) => IsBasvurusuDurumu.values.firstWhere(
        (durum) => durum.deger == deger,
        orElse: () => IsBasvurusuDurumu.beklemede,
      );
}

/// TS: `interface IsIlaniResponse`
class IsIlaniResponse {
  const IsIlaniResponse({
    required this.id,
    required this.firmaId,
    required this.firmaAdi,
    required this.baslik,
    required this.aciklama,
    required this.konum,
    required this.yayinTarihi,
    required this.durum,
  });

  final String id;
  final String firmaId;
  final String firmaAdi;
  final String baslik;
  final String aciklama;
  final String? konum;
  final DateTime yayinTarihi;
  final IsIlaniDurumu durum;

  factory IsIlaniResponse.jsondan(Map<String, dynamic> json) => IsIlaniResponse(
        id: json['id'] as String,
        firmaId: json['firmaId'] as String,
        firmaAdi: json['firmaAdi'] as String,
        baslik: json['baslik'] as String,
        aciklama: json['aciklama'] as String,
        konum: json['konum'] as String?,
        yayinTarihi: DateTime.parse(json['yayinTarihi'] as String),
        durum: IsIlaniDurumu.cozumle(json['durum'] as String?),
      );
}

/// TS: `interface IsIlaniOlusturRequest`
class IsIlaniOlusturRequest {
  const IsIlaniOlusturRequest({required this.baslik, required this.aciklama, this.konum});

  final String baslik;
  final String aciklama;
  final String? konum;

  Map<String, dynamic> jsonaDonustur() => {
        'baslik': baslik,
        'aciklama': aciklama,
        if (konum != null && konum!.isNotEmpty) 'konum': konum,
      };
}

/// TS: `interface IsBasvurusuResponse`
class IsBasvurusuResponse {
  const IsBasvurusuResponse({
    required this.id,
    required this.isIlaniId,
    required this.kullaniciId,
    required this.kullaniciAdSoyad,
    required this.basvuruTarihi,
    required this.durum,
    required this.cvUrl,
  });

  final String id;
  final String isIlaniId;
  final String kullaniciId;
  final String kullaniciAdSoyad;
  final DateTime basvuruTarihi;
  final IsBasvurusuDurumu durum;
  final String? cvUrl;

  factory IsBasvurusuResponse.jsondan(Map<String, dynamic> json) => IsBasvurusuResponse(
        id: json['id'] as String,
        isIlaniId: json['isIlaniId'] as String,
        kullaniciId: json['kullaniciId'] as String,
        kullaniciAdSoyad: json['kullaniciAdSoyad'] as String,
        basvuruTarihi: DateTime.parse(json['basvuruTarihi'] as String),
        durum: IsBasvurusuDurumu.cozumle(json['durum'] as String?),
        cvUrl: json['cvUrl'] as String?,
      );
}

/// TS: `interface IsBasvurusuDurumGuncelleRequest` — `beklemede` BİLEREK yok,
/// firma yetkilisi bir başvuruyu tekrar beklemeye alamaz.
enum IsBasvurusuKarari {
  incelendi('incelendi'),
  reddedildi('reddedildi'),
  kabul('kabul');

  const IsBasvurusuKarari(this.deger);

  final String deger;
}

/// TS: `interface BasvurumResponse` — `GET /is-ilanlari/basvurularim`.
/// `IsBasvurusuResponse`'tan farkı: o "bu ilana kim başvurdu" (firma
/// yetkilisi görünümü), bu "ben nereye başvurdum" (adayın kendi görünümü).
class BasvurumResponse {
  const BasvurumResponse({
    required this.id,
    required this.isIlaniId,
    required this.isIlaniBasligi,
    required this.firmaAdi,
    required this.basvuruTarihi,
    required this.durum,
    required this.cvUrl,
  });

  final String id;
  final String isIlaniId;
  final String isIlaniBasligi;
  final String firmaAdi;
  final DateTime basvuruTarihi;
  final IsBasvurusuDurumu durum;
  final String? cvUrl;

  factory BasvurumResponse.jsondan(Map<String, dynamic> json) => BasvurumResponse(
        id: json['id'] as String,
        isIlaniId: json['isIlaniId'] as String,
        isIlaniBasligi: json['isIlaniBasligi'] as String,
        firmaAdi: json['firmaAdi'] as String,
        basvuruTarihi: DateTime.parse(json['basvuruTarihi'] as String),
        durum: IsBasvurusuDurumu.cozumle(json['durum'] as String?),
        cvUrl: json['cvUrl'] as String?,
      );
}
