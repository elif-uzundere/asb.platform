import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';
import '../domain/acil_durum_bildirimi.dart';
import '../domain/acil_durum_birimi.dart';
import '../domain/toplanma_alani.dart';

class AcilDurumApi {
  const AcilDurumApi(
    this._dio,
  );

  final Dio _dio;

  Future<List<AcilDurumBirimi>>
      bilgileriGetir() {
    return apiIstegi(
      () => _dio.get<Map<String, dynamic>>(
        '/acil-durum/bilgiler',
      ),
      cozumle: (veri) {
        return (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(
              AcilDurumBirimi.jsondan,
            )
            .toList();
      },
      yedekMesaj:
          'Acil durum bilgileri yüklenemedi.',
    );
  }

  Future<List<ToplanmaAlani>>
      toplanmaAlanlariniGetir() {
    return apiIstegi(
      () => _dio.get<Map<String, dynamic>>(
        '/acil-durum/toplanma-alanlari',
      ),
      cozumle: (veri) {
        return (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(
              ToplanmaAlani.jsondan,
            )
            .toList();
      },
      yedekMesaj:
          'Toplanma alanları yüklenemedi.',
    );
  }

  Future<void> bildirimOlustur(AcilDurumTuru tur, String aciklama) => apiIstegi(
        () => _dio.post<Map<String, dynamic>>(
          '/acil-durum/bildirimler',
          data: {'tur': tur.deger, 'aciklama': aciklama},
        ),
        cozumle: (_) {},
        yedekMesaj: 'Bildirim gönderilemedi.',
      );

  Future<List<AcilDurumBildirimiResponse>> bildirimlerimGetir() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/acil-durum/bildirimlerim'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AcilDurumBildirimiResponse.jsondan)
            .toList(),
        yedekMesaj: 'Bildirimleriniz yüklenemedi.',
      );
}

final acilDurumApiProvider =
    Provider<AcilDurumApi>(
  (ref) {
    return AcilDurumApi(
      ref.watch(apiClientProvider),
    );
  },
);