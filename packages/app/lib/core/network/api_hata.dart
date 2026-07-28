import 'package:dio/dio.dart';

/// Backend `{ success: false, error: { code, message } }` zarfını taşıyan hata.
/// `error.message` zaten Türkçe ve kullanıcıya gösterilebilir metin —
/// kod→metin eşlemesi YAPILMAZ, doğrudan gösterilir.
class ApiHata implements Exception {
  const ApiHata(this.mesaj, {this.kod});

  final String mesaj;
  final String? kod;

  /// Ağ/sunucu hatasını kullanıcıya gösterilebilir bir [ApiHata]'ya çevirir.
  /// Backend mesajı yoksa [yedekMesaj] kullanılır.
  factory ApiHata.dioHatasindan(DioException hata, {required String yedekMesaj}) {
    final govde = hata.response?.data;
    if (govde is Map) {
      final detay = govde['error'];
      if (detay is Map && detay['message'] is String) {
        return ApiHata(
          detay['message'] as String,
          kod: detay['code'] as String?,
        );
      }
    }

    final baglantiSorunu = switch (hata.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        true,
      _ => false,
    };

    if (baglantiSorunu) {
      return const ApiHata('Sunucuya ulaşılamadı, bağlantını kontrol et.');
    }

    return ApiHata(yedekMesaj);
  }

  @override
  String toString() => mesaj;
}
