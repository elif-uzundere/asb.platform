// GET /firmalar, /firmalar/{id}, /firmalar/sektorler — hepsi oturum ister
// (backend'de @UseGuards(JwtAuthGuard)); dio interceptor token'ı zaten
// ekliyor (bkz. core/network/api_client.dart), burada ekstra bir şey yok.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/firma_modelleri.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';
import '../domain/firma_kurallari.dart';

class FirmaApi {
  const FirmaApi(this._dio);

  final Dio _dio;

  Future<List<FirmaResponse>> listele(FirmaSorgusu sorgu) => apiIstegi(
        () => _dio.get<Map<String, dynamic>>(
          '/firmalar',
          queryParameters: sorgu.sorguParametreleri(),
        ),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(FirmaResponse.jsondan)
            .toList(),
        yedekMesaj: 'Firmalar yüklenemedi.',
      );

  Future<FirmaResponse> detay(String id) => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/firmalar/$id'),
        cozumle: (veri) => FirmaResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Firma bulunamadı.',
      );

  Future<List<String>> sektorler() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/firmalar/sektorler'),
        cozumle: (veri) => (veri as List? ?? const []).whereType<String>().toList(),
        yedekMesaj: 'Sektörler yüklenemedi.',
      );
}

final firmaApiProvider =
    Provider<FirmaApi>((ref) => FirmaApi(ref.watch(apiClientProvider)));
