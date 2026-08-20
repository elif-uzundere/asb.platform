// İkinci El ilanı / Firma / İş İlanı, üçü için tek ortak favori API'si.
// Backend de tek `favori` tablosu kullanıyor, bkz.
// packages/backend/src/modules/favori.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/favori_modelleri.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';

class FavoriApi {
  const FavoriApi(this._dio);

  final Dio _dio;

  /// "Kalp" butonu — zaten favorideyse kaldırır, değilse ekler.
  /// Backend'in güncel durumunu (favoride mi) döner.
  Future<bool> durumDegistir(FavoriHedefTuru tur, String hedefId) => apiIstegi(
        () => _dio.post<Map<String, dynamic>>(
          '/favoriler',
          data: {'hedefTuru': tur.deger, 'hedefId': hedefId},
        ),
        cozumle: (veri) => (veri! as Map<String, dynamic>)['favoride'] as bool,
        yedekMesaj: 'Favori durumu değiştirilemedi.',
      );

  Future<Set<String>> favorilerimGetir(FavoriHedefTuru tur) => apiIstegi(
        () => _dio.get<Map<String, dynamic>>(
          '/favoriler',
          queryParameters: {'tur': tur.deger},
        ),
        cozumle: (veri) => (veri as List? ?? const []).whereType<String>().toSet(),
        yedekMesaj: 'Favoriler yüklenemedi.',
      );
}

final favoriApiProvider = Provider<FavoriApi>((ref) => FavoriApi(ref.watch(apiClientProvider)));
