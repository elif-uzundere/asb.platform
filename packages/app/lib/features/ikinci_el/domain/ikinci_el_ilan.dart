class IkinciElIlan {
  const IkinciElIlan({
    required this.id,
    required this.baslik,
    required this.aciklama,
    required this.kategori,
    required this.fiyat,
    required this.durum,
    required this.firmaAdi,
    required this.gorselUrl,
    required this.fotografUrls,
    required this.iletisimTelefonu,
    required this.oneCikan,
    required this.olusturulmaTarihi,
  });

  final String id;
  final String baslik;
  final String aciklama;
  final String kategori;
  final double fiyat;

  /// Ürünün fiziksel durumu:
  /// Örn: "Yeni gibi", "İyi durumda", "Kullanılmış"
  final String durum;

  final String firmaAdi;
  final String gorselUrl;
  final List<String> fotografUrls;
  final String iletisimTelefonu;
  final bool oneCikan;
  final DateTime olusturulmaTarihi;

  factory IkinciElIlan.jsondan(
    Map<String, dynamic> json,
  ) {
    final fotografUrls =
        (json['fotografUrls'] as List? ?? const [])
            .whereType<String>()
            .toList();

    return IkinciElIlan(
      id: json['id'] as String,
      baslik: json['baslik'] as String? ?? '',
      aciklama: json['aciklama'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      fiyat: (json['fiyat'] as num?)?.toDouble() ?? 0,
      durum: json['urunDurumu'] as String? ?? '',
      firmaAdi: json['firmaAdi'] as String? ?? '',
      gorselUrl: json['gorselUrl'] as String? ??
          (fotografUrls.isNotEmpty
              ? fotografUrls.first
              : ''),
      fotografUrls: fotografUrls,
      iletisimTelefonu:
          json['iletisimTelefonu'] as String? ?? '',
      oneCikan: json['oneCikan'] as bool? ?? false,
      olusturulmaTarihi: DateTime.tryParse(
            json['olusturmaTarihi'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }
}