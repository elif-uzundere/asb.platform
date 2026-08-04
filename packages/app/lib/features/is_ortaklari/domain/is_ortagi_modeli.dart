class IsOrtagiModeli {
  const IsOrtagiModeli({
    required this.id,
    required this.ad,
    required this.logoUrl,
    this.kategori,
  });

  final String id;
  final String ad;
  final String logoUrl;
  final String? kategori;

  factory IsOrtagiModeli.fromJson(
    Map<String, dynamic> json,
  ) {
    return IsOrtagiModeli(
      id: json['id'] as String,
      ad: json['ad'] as String,
      logoUrl: json['logoUrl'] as String,
      kategori: json['kategori'] as String?,
    );
  }
}