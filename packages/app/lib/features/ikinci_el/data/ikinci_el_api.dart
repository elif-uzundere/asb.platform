import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';
import '../domain/ikinci_el_ilan.dart';

class IkinciElApi {
  const IkinciElApi(this._dio);

  final Dio _dio;

  /// Aktif ikinci el ilanlarını backend'den getirir.
  ///
  /// GET /ikinci-el-pazar
  Future<List<IkinciElIlan>> ilanlariGetir() {
    return apiIstegi(
      () => _dio.get<Map<String, dynamic>>(
        '/ikinci-el-pazar',
      ),
      cozumle: (veri) {
        return (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(IkinciElIlan.jsondan)
            .toList();
      },
      yedekMesaj:
          'İkinci el ilanları yüklenemedi.',
    );
  }

  /// Yeni ikinci el ilanı oluşturur.
  ///
  /// Şehir Flutter tarafından gönderilmez.
  /// Backend konumu otomatik olarak belirler.
  ///
  /// POST /ikinci-el-pazar
  Future<IkinciElIlan> ilanOlustur({
    required String baslik,
    required String aciklama,
    required double fiyat,
    required String kategori,
    required String urunDurumu,
    required List<String> fotografUrls,
  }) {
    return apiIstegi(
      () => _dio.post<Map<String, dynamic>>(
        '/ikinci-el-pazar',
        data: {
          'baslik': baslik,
          'aciklama': aciklama,
          'fiyat': fiyat,
          'kategori': kategori,
          'urunDurumu': urunDurumu,
          'fotografUrls': fotografUrls,
        },
      ),
      cozumle: (veri) {
        return IkinciElIlan.jsondan(
          veri as Map<String, dynamic>,
        );
      },
      yedekMesaj:
          'İlan oluşturulamadı.',
    );
  }
}

final ikinciElApiProvider =
    Provider<IkinciElApi>((ref) {
  return IkinciElApi(
    ref.watch(apiClientProvider),
  );
});