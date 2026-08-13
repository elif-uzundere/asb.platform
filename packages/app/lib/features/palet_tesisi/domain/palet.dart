class Palet {
  const Palet({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.olcu,
    required this.gorselUrl,
    required this.aktif,
    required this.sira,
  });

  final String id;
  final String ad;
  final String? aciklama;
  final String? olcu;
  final String? gorselUrl;
  final bool aktif;
  final int sira;

  factory Palet.jsondan(
    Map<String, dynamic> json,
  ) {
    return Palet(
      id: json['id'] as String? ?? '',
      ad: json['ad'] as String? ?? '',
      aciklama: json['aciklama'] as String?,
      olcu: json['olcu'] as String?,
      gorselUrl: json['gorselUrl'] as String?,
      aktif: json['aktif'] as bool? ?? true,
      sira: json['sira'] as int? ?? 0,
    );
  }
}