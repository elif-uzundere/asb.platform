class PaletTesisiBilgisi {
  const PaletTesisiBilgisi({
    required this.id,
    required this.telefon,
    required this.eposta,
    required this.adres,
    required this.aciklama,
    required this.calismaSaatleri,
  });

  final String id;
  final String? telefon;
  final String? eposta;
  final String? adres;
  final String? aciklama;
  final String? calismaSaatleri;

  factory PaletTesisiBilgisi.jsondan(
    Map<String, dynamic> json,
  ) {
    return PaletTesisiBilgisi(
      id: json['id'] as String? ?? '',
      telefon: json['telefon'] as String?,
      eposta: json['eposta'] as String?,
      adres: json['adres'] as String?,
      aciklama: json['aciklama'] as String?,
      calismaSaatleri:
          json['calismaSaatleri'] as String?,
    );
  }
}