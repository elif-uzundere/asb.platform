// GET /banners — sadece aktif banner'lar, backend `sira`'ya göre sıralı döndürür.
// Yanıt ApiResponseDto zarfında: { success, data: BannerResponse[] }

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/banner_modelleri.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';

class BannerApi {
  const BannerApi(this._dio);

  final Dio _dio;

  Future<List<BannerResponse>> bannerlariGetir() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/banners'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(BannerResponse.jsondan)
            .toList(),
        yedekMesaj: 'Bannerlar yüklenemedi.',
      );
}

final bannerApiProvider =
    Provider<BannerApi>((ref) => BannerApi(ref.watch(apiClientProvider)));

final bannerlarProvider = FutureProvider<List<BannerResponse>>(
  (ref) => ref.watch(bannerApiProvider).bannerlariGetir(),
);
