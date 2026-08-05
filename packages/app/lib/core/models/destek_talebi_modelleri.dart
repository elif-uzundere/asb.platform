// Kaynak: packages/shared-types/src/destek-talebi.types.ts
// Manuel mirror — bkz. lib/core/models/auth_modelleri.dart başındaki not.

/// TS: `type DestekTalebiDurumu`
enum DestekTalebiDurumu {
  beklemede('beklemede'),
  yanitlandi('yanitlandi'),
  kapali('kapali');

  const DestekTalebiDurumu(this.deger);

  final String deger;

  static DestekTalebiDurumu cozumle(String? deger) => DestekTalebiDurumu.values.firstWhere(
        (durum) => durum.deger == deger,
        orElse: () => DestekTalebiDurumu.beklemede,
      );

  String get gorunenAd => switch (this) {
        DestekTalebiDurumu.beklemede => 'Beklemede',
        DestekTalebiDurumu.yanitlandi => 'Yanıtlandı',
        DestekTalebiDurumu.kapali => 'Kapalı',
      };
}

/// TS: `interface DestekTalebiOlusturRequest`
class DestekTalebiOlusturRequest {
  const DestekTalebiOlusturRequest({required this.baslik, required this.aciklama});

  final String baslik;
  final String aciklama;

  Map<String, dynamic> jsonaDonustur() => {'baslik': baslik, 'aciklama': aciklama};
}

/// TS: `interface DestekTalebiResponse`
class DestekTalebiResponse {
  const DestekTalebiResponse({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.durum,
    required this.olusturmaTarihi,
  });

  final String id;
  final String baslik;
  final String aciklama;
  final DestekTalebiDurumu durum;
  final DateTime olusturmaTarihi;

  factory DestekTalebiResponse.jsondan(Map<String, dynamic> json) => DestekTalebiResponse(
        id: json['id'] as String,
        baslik: json['baslik'] as String,
        aciklama: json['aciklama'] as String,
        durum: DestekTalebiDurumu.cozumle(json['durum'] as String?),
        olusturmaTarihi: DateTime.parse(json['olusturmaTarihi'] as String),
      );
}
