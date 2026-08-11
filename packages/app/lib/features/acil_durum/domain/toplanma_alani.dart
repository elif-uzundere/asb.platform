class ToplanmaAlani {
  const ToplanmaAlani({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.enlem,
    required this.boylam,
    required this.sira,
  });

  final String id;
  final String ad;
  final String? aciklama;
  final double enlem;
  final double boylam;
  final int sira;

  factory ToplanmaAlani.jsondan(
    Map<String, dynamic> json,
  ) {
    return ToplanmaAlani(
      id: json['id'] as String,
      ad: json['ad'] as String? ?? '',
      aciklama: json['aciklama'] as String?,
      enlem: (json['enlem'] as num).toDouble(),
      boylam: (json['boylam'] as num).toDouble(),
      sira: json['sira'] as int? ?? 0,
    );
  }
}