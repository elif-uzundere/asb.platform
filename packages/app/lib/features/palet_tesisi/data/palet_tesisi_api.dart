import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';
import '../domain/palet.dart';
import '../domain/palet_tesisi_bilgisi.dart';

class PaletTesisiApi {
  const PaletTesisiApi(this._dio);

  final Dio _dio;

  Future<PaletTesisiBilgisi?>
      tesisBilgisiGetir() {
    return apiIstegi(
      () => _dio.get<Map<String, dynamic>>(
        '/palet-tesisi/bilgi',
      ),
      cozumle: (veri) {
        if (veri == null) {
          return null;
        }

        return PaletTesisiBilgisi.jsondan(
          veri as Map<String, dynamic>,
        );
      },
      yedekMesaj:
          'Palet tesisi bilgileri yüklenemedi.',
    );
  }

  Future<List<Palet>>
      paletleriGetir() {
    return apiIstegi(
      () => _dio.get<Map<String, dynamic>>(
        '/palet-tesisi/paletler',
      ),
      cozumle: (veri) {
        return (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(Palet.jsondan)
            .toList();
      },
      yedekMesaj:
          'Paletler yüklenemedi.',
    );
  }
}

final paletTesisiApiProvider =
    Provider<PaletTesisiApi>(
  (ref) {
    return PaletTesisiApi(
      ref.watch(apiClientProvider),
    );
  },
);