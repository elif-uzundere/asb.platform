// Kaynak: packages/shared-types/src/acil-durum.types.ts

/// TS: `export type AcilDurumTuru = 'yangin' | 'kaza' | 'saglik' | 'kantar' | 'gumruk' | 'diger'`
enum AcilDurumTuru {
  yangin('yangin', 'Yangın'),
  kaza('kaza', 'Kaza'),
  saglik('saglik', 'Sağlık'),
  kantar('kantar', 'Kantar'),
  gumruk('gumruk', 'Gümrük'),
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

/// TS: `interface EkibeGelenBildirimResponse` — `GET /acil-durum/ekip/bildirimler`.
class EkibeGelenBildirimResponse {
  const EkibeGelenBildirimResponse({
    required this.id,
    required this.tur,
    required this.aciklama,
    required this.durum,
    required this.bildirenAdSoyad,
    required this.olusturmaTarihi,
  });

  final String id;
  final AcilDurumTuru tur;
  final String? aciklama;
  final AcilDurumBildirimDurumu durum;
  final String bildirenAdSoyad;
  final DateTime olusturmaTarihi;

  factory EkibeGelenBildirimResponse.jsondan(Map<String, dynamic> json) => EkibeGelenBildirimResponse(
        id: json['id'] as String,
        tur: AcilDurumTuru.values.firstWhere(
          (t) => t.deger == json['tur'],
          orElse: () => AcilDurumTuru.diger,
        ),
        aciklama: json['aciklama'] as String?,
        durum: AcilDurumBildirimDurumu.cozumle(json['durum'] as String?),
        bildirenAdSoyad: json['bildirenAdSoyad'] as String? ?? 'Bilinmeyen Kullanıcı',
        olusturmaTarihi: DateTime.parse(json['olusturmaTarihi'] as String),
      );
}

/// TS: `interface AcilDurumBildirimDurumGuncelleRequest` — `yeni` BİLEREK yok.
enum AcilDurumKarari {
  inceleniyor('inceleniyor', 'İncelemeye Al'),
  kapatildi('kapatildi', 'Kapat');

  const AcilDurumKarari(this.deger, this.etiket);

  final String deger;
  final String etiket;
}
