// Kaynak: packages/shared-types/src/cookzone.types.ts
//
// packages/shared-types bir TypeScript paketi ve Dart'tan import edilemiyor;
// bu yüzden tipler burada EL İLE yansıtılıyor (manuel mirror, bkz.
// auth_modelleri.dart başındaki not).

/// TS: `export type CookzoneSiparisDurumu`
enum CookzoneSiparisDurumu {
  beklemede('beklemede'),
  alindi('alindi'),
  hazirlaniyor('hazirlaniyor'),
  hazir('hazir'),
  teslimEdildi('teslim_edildi');

  const CookzoneSiparisDurumu(this.deger);

  final String deger;

  static CookzoneSiparisDurumu cozumle(String? deger) => CookzoneSiparisDurumu.values.firstWhere(
        (durum) => durum.deger == deger,
        orElse: () => CookzoneSiparisDurumu.beklemede,
      );
}

/// TS: `interface CookzoneMenuOgesiResponse`
class CookzoneMenuOgesiResponse {
  const CookzoneMenuOgesiResponse({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.fiyat,
    required this.kategori,
    required this.gorselUrl,
    this.aktif = true,
  });

  final String id;
  final String ad;
  final String? aciklama;
  final num fiyat;
  final String kategori;
  final String? gorselUrl;
  final bool aktif;

  factory CookzoneMenuOgesiResponse.jsondan(Map<String, dynamic> json) => CookzoneMenuOgesiResponse(
        id: json['id'] as String,
        ad: json['ad'] as String,
        aciklama: json['aciklama'] as String?,
        fiyat: json['fiyat'] as num,
        kategori: json['kategori'] as String,
        gorselUrl: json['gorselUrl'] as String?,
        aktif: json['aktif'] as bool? ?? true,
      );
}

/// TS: `interface CookzoneIsletmeResponse`
class CookzoneIsletmeResponse {
  const CookzoneIsletmeResponse({
    required this.id,
    required this.ad,
    required this.bolgeNoktasiAdi,
    required this.menuOgeleri,
  });

  final String id;
  final String ad;
  final String bolgeNoktasiAdi;
  final List<CookzoneMenuOgesiResponse> menuOgeleri;

  factory CookzoneIsletmeResponse.jsondan(Map<String, dynamic> json) => CookzoneIsletmeResponse(
        id: json['id'] as String,
        ad: json['ad'] as String,
        bolgeNoktasiAdi: json['bolgeNoktasiAdi'] as String,
        menuOgeleri: (json['menuOgeleri'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CookzoneMenuOgesiResponse.jsondan)
            .toList(),
      );
}

/// TS: `interface CookzoneSiparisKalemiRequest`
class CookzoneSiparisKalemiRequest {
  const CookzoneSiparisKalemiRequest({required this.menuOgesiId, required this.adet});

  final String menuOgesiId;
  final int adet;

  Map<String, dynamic> jsonaDonustur() => {'menuOgesiId': menuOgesiId, 'adet': adet};
}

/// TS: `interface CookzoneSiparisOlusturRequest`
class CookzoneSiparisOlusturRequest {
  const CookzoneSiparisOlusturRequest({
    required this.isletmeId,
    required this.alinmaSaati,
    required this.kalemler,
  });

  final String isletmeId;
  /// ISO 8601 string — JSON'da Date yok.
  final String alinmaSaati;
  final List<CookzoneSiparisKalemiRequest> kalemler;

  Map<String, dynamic> jsonaDonustur() => {
        'isletmeId': isletmeId,
        'alinmaSaati': alinmaSaati,
        'kalemler': kalemler.map((k) => k.jsonaDonustur()).toList(),
      };
}

/// TS: `interface CookzoneSiparisKalemiResponse`
class CookzoneSiparisKalemiResponse {
  const CookzoneSiparisKalemiResponse({
    required this.id,
    required this.menuOgesiAdi,
    required this.adet,
    required this.birimFiyat,
  });

  final String id;
  final String menuOgesiAdi;
  final int adet;
  final num birimFiyat;

  factory CookzoneSiparisKalemiResponse.jsondan(Map<String, dynamic> json) => CookzoneSiparisKalemiResponse(
        id: json['id'] as String,
        menuOgesiAdi: json['menuOgesiAdi'] as String,
        adet: json['adet'] as int,
        birimFiyat: json['birimFiyat'] as num,
      );
}

/// TS: `interface CookzoneSiparisResponse` — müşterinin kendi siparişi.
class CookzoneSiparisResponse {
  const CookzoneSiparisResponse({
    required this.id,
    required this.isletmeId,
    required this.isletmeAdi,
    required this.durum,
    required this.toplamTutar,
    required this.alinmaSaati,
    required this.olusturmaTarihi,
    required this.kalemler,
  });

  final String id;
  final String isletmeId;
  final String isletmeAdi;
  final CookzoneSiparisDurumu durum;
  final num toplamTutar;
  final DateTime alinmaSaati;
  final DateTime olusturmaTarihi;
  final List<CookzoneSiparisKalemiResponse> kalemler;

  factory CookzoneSiparisResponse.jsondan(Map<String, dynamic> json) => CookzoneSiparisResponse(
        id: json['id'] as String,
        isletmeId: json['isletmeId'] as String,
        isletmeAdi: json['isletmeAdi'] as String,
        durum: CookzoneSiparisDurumu.cozumle(json['durum'] as String?),
        toplamTutar: json['toplamTutar'] as num,
        alinmaSaati: DateTime.parse(json['alinmaSaati'] as String),
        olusturmaTarihi: DateTime.parse(json['olusturmaTarihi'] as String),
        kalemler: (json['kalemler'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CookzoneSiparisKalemiResponse.jsondan)
            .toList(),
      );
}

/// TS: `interface CookzoneSiparisYonetimResponse` — cookzone_yetkilisi görünümü.
class CookzoneSiparisYonetimResponse {
  const CookzoneSiparisYonetimResponse({
    required this.id,
    required this.kullaniciAdSoyad,
    required this.durum,
    required this.toplamTutar,
    required this.alinmaSaati,
    required this.olusturmaTarihi,
    required this.kalemler,
  });

  final String id;
  final String kullaniciAdSoyad;
  final CookzoneSiparisDurumu durum;
  final num toplamTutar;
  final DateTime alinmaSaati;
  final DateTime olusturmaTarihi;
  final List<CookzoneSiparisKalemiResponse> kalemler;

  factory CookzoneSiparisYonetimResponse.jsondan(Map<String, dynamic> json) => CookzoneSiparisYonetimResponse(
        id: json['id'] as String,
        kullaniciAdSoyad: json['kullaniciAdSoyad'] as String,
        durum: CookzoneSiparisDurumu.cozumle(json['durum'] as String?),
        toplamTutar: json['toplamTutar'] as num,
        alinmaSaati: DateTime.parse(json['alinmaSaati'] as String),
        olusturmaTarihi: DateTime.parse(json['olusturmaTarihi'] as String),
        kalemler: (json['kalemler'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CookzoneSiparisKalemiResponse.jsondan)
            .toList(),
      );
}
