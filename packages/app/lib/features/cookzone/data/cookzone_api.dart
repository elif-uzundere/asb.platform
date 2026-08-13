// GET uçları katalog modeli (girişsiz de çalışır), sipariş verme/yönetme
// kişiye özel — dio interceptor token'ı zaten ekliyor.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/cookzone_modelleri.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';

class CookzoneApi {
  const CookzoneApi(this._dio);

  final Dio _dio;

  Future<List<CookzoneIsletmeResponse>> isletmeler() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/cookzone/isletmeler'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CookzoneIsletmeResponse.jsondan)
            .toList(),
        yedekMesaj: 'Yemek noktaları yüklenemedi.',
      );

  Future<CookzoneIsletmeResponse> isletmeDetay(String id) => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/cookzone/isletmeler/$id'),
        cozumle: (veri) => CookzoneIsletmeResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Yemek noktası bulunamadı.',
      );

  Future<CookzoneSiparisResponse> siparisOlustur(CookzoneSiparisOlusturRequest dto) => apiIstegi(
        () => _dio.post<Map<String, dynamic>>('/cookzone/siparisler', data: dto.jsonaDonustur()),
        cozumle: (veri) => CookzoneSiparisResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Sipariş oluşturulamadı.',
      );

  Future<List<CookzoneSiparisResponse>> siparislerim() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/cookzone/siparislerim'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CookzoneSiparisResponse.jsondan)
            .toList(),
        yedekMesaj: 'Siparişleriniz yüklenemedi.',
      );

  Future<List<CookzoneSiparisYonetimResponse>> isletmeSiparisleri() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/cookzone/siparisler'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CookzoneSiparisYonetimResponse.jsondan)
            .toList(),
        yedekMesaj: 'Sipariş kuyruğu yüklenemedi.',
      );

  Future<CookzoneSiparisYonetimResponse> siparisIlerlet(String id) => apiIstegi(
        () => _dio.put<Map<String, dynamic>>('/cookzone/siparisler/$id/ilerlet'),
        cozumle: (veri) => CookzoneSiparisYonetimResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Sipariş ilerletilemedi.',
      );
}

final cookzoneApiProvider = Provider<CookzoneApi>((ref) => CookzoneApi(ref.watch(apiClientProvider)));
