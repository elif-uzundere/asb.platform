// POST/GET /destek-talepleri — oturum ister (backend JwtAuthGuard sınıf
// seviyesinde), dio interceptor token'ı zaten ekliyor.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/destek_talebi_modelleri.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';

class DestekTalebiApi {
  const DestekTalebiApi(this._dio);

  final Dio _dio;

  Future<DestekTalebiResponse> olustur(DestekTalebiOlusturRequest dto) => apiIstegi(
        () => _dio.post<Map<String, dynamic>>(
          '/destek-talepleri',
          data: dto.jsonaDonustur(),
        ),
        cozumle: (veri) => DestekTalebiResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Destek talebi oluşturulamadı.',
      );

  Future<List<DestekTalebiResponse>> listele() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/destek-talepleri'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(DestekTalebiResponse.jsondan)
            .toList(),
        yedekMesaj: 'Taleplerim yüklenemedi.',
      );
}

final destekTalebiApiProvider =
    Provider<DestekTalebiApi>((ref) => DestekTalebiApi(ref.watch(apiClientProvider)));
