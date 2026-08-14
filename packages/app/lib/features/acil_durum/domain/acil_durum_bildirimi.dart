// Kaynak: packages/shared-types/src/acil-durum.types.ts

/// TS: `export type AcilDurumTuru = 'yangin' | 'kaza' | 'saglik' | 'diger'`
enum AcilDurumTuru {
  yangin('yangin', 'Yangın'),
  kaza('kaza', 'Kaza'),
  saglik('saglik', 'Sağlık'),
  diger('diger', 'Diğer');

  const AcilDurumTuru(this.deger, this.etiket);

  final String deger;
  final String etiket;
}

/// TS: `export type AcilDurumBildirimDurumu = 'yeni' | 'inceleniyor' | 'kapatildi'`
enum AcilDurumBildirimDurumu {
  yeni('yeni', 'Yeni'),
  inceleniyor('inceleniyor', 'İnceleniyor'),
  kapatildi('kapatildi', 'Kapatıldı');

  const AcilDurumBildirimDurumu(this.deger, this.etiket);

  final String deger;
  final String etiket;

  static AcilDurumBildirimDurumu cozumle(String? deger) => AcilDurumBildirimDurumu.values.firstWhere(
        (durum) => durum.deger == deger,
        orElse: () => AcilDurumBildirimDurumu.yeni,
      );
}

/// TS: `interface AcilDurumBildirimiResponse`
class AcilDurumBildirimiResponse {
  const AcilDurumBildirimiResponse({
    required this.id,
    required this.tur,
    required this.aciklama,
    required this.durum,
    required this.olusturmaTarihi,
  });

  final String id;
  final AcilDurumTuru tur;
  final String? aciklama;
  final AcilDurumBildirimDurumu durum;
  final DateTime olusturmaTarihi;

  factory AcilDurumBildirimiResponse.jsondan(Map<String, dynamic> json) => AcilDurumBildirimiResponse(
        id: json['id'] as String,
        tur: AcilDurumTuru.values.firstWhere(
          (t) => t.deger == json['tur'],
          orElse: () => AcilDurumTuru.diger,
        ),
        aciklama: json['aciklama'] as String?,
        durum: AcilDurumBildirimDurumu.cozumle(json['durum'] as String?),
        olusturmaTarihi: DateTime.parse(json['olusturmaTarihi'] as String),
      );
}
