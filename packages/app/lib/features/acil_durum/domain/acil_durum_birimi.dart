class AcilDurumBirimi {
  const AcilDurumBirimi({
    required this.id,
    required this.tur,
    required this.ad,
    required this.altBaslik,
    required this.telefon,
    required this.eposta,
    required this.adres,
    required this.aciklama,
    required this.calismaSaatleri,
    required this.sira,
  });

  final String id;
  final String tur;

  // Flutter tarafında sabit bilgiler.
  final String ad;
  final String altBaslik;
  final int sira;

  // Backend / veritabanından gelen bilgiler.
  final String? telefon;
  final String? eposta;
  final String? adres;
  final String? aciklama;
  final String? calismaSaatleri;

  static const List<String> sabitTurler = [
    'isg',
    'itfaiye',
    'guvenlik',
    'musteri_hizmetleri',
    'kantar',
    'gumruk',
  ];

  factory AcilDurumBirimi.jsondan(
    Map<String, dynamic> json,
  ) {
    final tur =
        (json['tur'] as String? ?? '').trim().toLowerCase();

    return AcilDurumBirimi(
      id: json['id'] as String? ?? '',
      tur: tur,
      ad: _adBul(tur),
      altBaslik: _altBaslikBul(tur),
      telefon: json['telefon'] as String?,
      eposta: json['eposta'] as String?,
      adres: json['adres'] as String?,
      aciklama: json['aciklama'] as String?,
      calismaSaatleri:
          json['calismaSaatleri'] as String?,
      sira: _siraBul(tur),
    );
  }

  factory AcilDurumBirimi.bos(
    String tur,
  ) {
    final temizTur =
        tur.trim().toLowerCase();

    return AcilDurumBirimi(
      id: '',
      tur: temizTur,
      ad: _adBul(temizTur),
      altBaslik: _altBaslikBul(temizTur),
      telefon: null,
      eposta: null,
      adres: null,
      aciklama: null,
      calismaSaatleri: null,
      sira: _siraBul(temizTur),
    );
  }

  static String _adBul(
    String tur,
  ) {
    switch (tur) {
      case 'isg':
        return 'Tekin İSG';

      case 'itfaiye':
        return 'İtfaiye';

      case 'guvenlik':
        return 'Güvenlik';

      case 'musteri_hizmetleri':
        return 'ASB Müşteri Hizmetleri';

      case 'kantar':
        return 'Kantar';

      case 'gumruk':
        return 'Gümrük';

      default:
        return 'Bilgi';
    }
  }

  static String _altBaslikBul(
    String tur,
  ) {
    switch (tur) {
      case 'isg':
        return 'İSG bilgileri ve iletişim';

      case 'itfaiye':
        return 'İtfaiye iletişim bilgileri';

      case 'guvenlik':
        return 'Güvenlik birimi iletişim';

      case 'musteri_hizmetleri':
        return 'ASB ile iletişim';

      case 'kantar':
        return 'Kantar bilgileri';

      case 'gumruk':
        return 'Gümrük birimi bilgileri';

      default:
        return '';
    }
  }

  static int _siraBul(
    String tur,
  ) {
    switch (tur) {
      case 'isg':
        return 1;

      case 'itfaiye':
        return 2;

      case 'guvenlik':
        return 3;

      case 'musteri_hizmetleri':
        return 4;

      case 'kantar':
        return 5;

      case 'gumruk':
        return 6;

      default:
        return 99;
    }
  }
}