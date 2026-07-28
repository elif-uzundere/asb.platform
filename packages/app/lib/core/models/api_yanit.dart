// Kaynak: packages/backend/src/shared/web/api-response.dto.ts
// Backend'in TÜM endpoint'lerde kullandığı response zarfı:
// { success: bool, data?: T, error?: { code, message } }
//
// Burada `data` ham (Object?) bırakılıyor; tipe dönüştürme işi çağıran
// modülün kendi modelinde (bkz. core/network/api_istegi.dart).

class ApiHataDetayi {
  const ApiHataDetayi({required this.code, required this.message});

  final String code;

  /// Backend'den gelen Türkçe, kullanıcıya gösterilebilir metin.
  final String message;

  static ApiHataDetayi? jsondanCozumle(Object? ham) {
    if (ham is! Map) return null;
    final mesaj = ham['message'];
    if (mesaj is! String) return null;
    return ApiHataDetayi(
      code: ham['code'] as String? ?? 'BILINMEYEN_HATA',
      message: mesaj,
    );
  }
}

class ApiYanit {
  const ApiYanit({required this.success, this.data, this.error});

  final bool success;

  /// Ham `data` alanı — `null` dönen endpoint'ler de var (ör. /auth/sifremi-unuttum).
  final Object? data;

  final ApiHataDetayi? error;

  factory ApiYanit.jsondan(Map<String, dynamic>? govde) => ApiYanit(
        success: govde?['success'] == true,
        data: govde?['data'],
        error: ApiHataDetayi.jsondanCozumle(govde?['error']),
      );
}
