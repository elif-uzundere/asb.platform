// GET /duyurular, /duyurular/{id} — oturum ister (backend JwtAuthGuard),
// dio interceptor token'ı zaten ekliyor (bkz. core/network/api_client.dart).

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/duyuru_modelleri.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';

class DuyuruApi {
  const DuyuruApi(this._dio);

  final Dio _dio;

  Future<List<DuyuruResponse>> listele() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/duyurular'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(DuyuruResponse.jsondan)
            .toList(),
        yedekMesaj: 'Duyurular yüklenemedi.',
      );

  Future<DuyuruResponse> detay(String id) => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/duyurular/$id'),
        cozumle: (veri) => DuyuruResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Duyuru bulunamadı.',
      );
}

final duyuruApiProvider =
    Provider<DuyuruApi>((ref) => DuyuruApi(ref.watch(apiClientProvider)));
