// Backend ile konuşan TÜM data katmanlarının ortak giriş noktası.
//
// Zarf çözme (`success` kontrolü), hata mesajını çıkarma ve ağ hatasını
// [ApiHata]'ya çevirme burada tek yerde yapılır — her modülün `*_api.dart`
// dosyası bunu yeniden yazmaz (bkz. docs/YENI-MODUL-REHBERI.md).

import 'package:dio/dio.dart';

import '../models/api_yanit.dart';
import 'api_hata.dart';

/// [istek]'i çalıştırır, zarfı çözer ve `data`'yı [cozumle] ile modele çevirir.
///
/// Başarısız zarf veya ağ hatası durumunda [ApiHata] fırlatır; mesaj olarak
/// backend'in Türkçe `error.message`'ı, o yoksa [yedekMesaj] kullanılır.
Future<T> apiIstegi<T>(
  Future<Response<Map<String, dynamic>>> Function() istek, {
  required T Function(Object? veri) cozumle,
  required String yedekMesaj,
}) async {
  try {
    final yanit = ApiYanit.jsondan((await istek()).data);

    if (!yanit.success) {
      final hata = yanit.error;
      throw ApiHata(hata?.message ?? yedekMesaj, kod: hata?.code);
    }

    return cozumle(yanit.data);
  } on DioException catch (hata) {
    throw ApiHata.dioHatasindan(hata, yedekMesaj: yedekMesaj);
  }
}
