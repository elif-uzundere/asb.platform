// Kaynak: packages/shared-types/src/duyuru.types.ts
// Manuel mirror — bkz. lib/core/models/auth_modelleri.dart başındaki not.

/// TS: `interface DuyuruResponse` — GET /duyurular ve GET /duyurular/{id}'nin
/// `data` alanı.
class DuyuruResponse {
  const DuyuruResponse({
    required this.id,
    required this.baslik,
    required this.icerik,
    required this.kategori,
    required this.yayinTarihi,
  });

  final String id;
  final String baslik;
  final String icerik;
  final String? kategori;
  final DateTime yayinTarihi;

  factory DuyuruResponse.jsondan(Map<String, dynamic> json) => DuyuruResponse(
        id: json['id'] as String,
        baslik: json['baslik'] as String,
        icerik: json['icerik'] as String,
        kategori: json['kategori'] as String?,
        yayinTarihi: DateTime.parse(json['yayinTarihi'] as String),
      );
}
