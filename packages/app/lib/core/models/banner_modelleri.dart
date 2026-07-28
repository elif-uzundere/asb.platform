// Kaynak: packages/shared-types/src/banner.types.ts
// Manuel mirror — bkz. lib/core/models/auth_modelleri.dart başındaki not.

/// TS: `interface BannerResponse` — GET /banners'ın `data` dizisinin elemanı.
class BannerResponse {
  const BannerResponse({
    required this.id,
    required this.gorselUrl,
    required this.linkUrl,
    required this.sira,
  });

  final String id;
  final String gorselUrl;

  /// null ise banner tıklanabilir değil.
  final String? linkUrl;
  final int sira;

  factory BannerResponse.jsondan(Map<String, dynamic> json) => BannerResponse(
        id: json['id'] as String,
        gorselUrl: json['gorselUrl'] as String,
        linkUrl: json['linkUrl'] as String?,
        sira: (json['sira'] as num?)?.toInt() ?? 0,
      );
}
