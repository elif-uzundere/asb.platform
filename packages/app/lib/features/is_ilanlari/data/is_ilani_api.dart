// GET uçları katalog modeli (girişsiz de çalışır), POST/PUT'lar
// JwtAuthGuard+RollerGuard('firma_yetkilisi') ister — dio interceptor
// token'ı zaten ekliyor (bkz. core/network/api_client.dart), burada ekstra
// bir şey yapmaya gerek yok.

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/is_ilani_modelleri.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';

class IsIlaniApi {
  const IsIlaniApi(this._dio);

  final Dio _dio;

  Future<List<IsIlaniResponse>> listele({String? firmaId}) => apiIstegi(
        () => _dio.get<Map<String, dynamic>>(
          '/is-ilanlari',
          queryParameters: firmaId == null ? null : {'firmaId': firmaId},
        ),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(IsIlaniResponse.jsondan)
            .toList(),
        yedekMesaj: 'İş ilanları yüklenemedi.',
      );

  Future<IsIlaniResponse> detay(String id) => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/is-ilanlari/$id'),
        cozumle: (veri) => IsIlaniResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'İlan bulunamadı.',
      );

  Future<IsIlaniResponse> olustur(IsIlaniOlusturRequest dto) => apiIstegi(
        () => _dio.post<Map<String, dynamic>>('/is-ilanlari', data: dto.jsonaDonustur()),
        cozumle: (veri) => IsIlaniResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'İlan oluşturulamadı.',
      );

  Future<IsIlaniResponse> kapat(String id) => apiIstegi(
        () => _dio.put<Map<String, dynamic>>('/is-ilanlari/$id/kapat'),
        cozumle: (veri) => IsIlaniResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'İlan kapatılamadı.',
      );

  /// `cvBaytlari` opsiyonel — seçilmezse dosyasız (eski davranış gibi)
  /// başvurulur. Bayt tabanlı (dosya yolu değil) çünkü web'de gerçek bir
  /// dosya sistemi yolu yok — `FilePicker.platform.pickFiles(withData: true)`
  /// her platformda çalışan tek ortak API.
  Future<void> basvur(String id, {Uint8List? cvBaytlari, String? cvDosyaAdi}) => apiIstegi(
        () => _dio.post<Map<String, dynamic>>(
          '/is-ilanlari/$id/basvur',
          data: cvBaytlari == null
              ? null
              : FormData.fromMap({
                  'cv': MultipartFile.fromBytes(cvBaytlari, filename: cvDosyaAdi ?? 'cv.pdf'),
                }),
        ),
        cozumle: (_) {},
        yedekMesaj: 'Başvuru gönderilemedi.',
      );

  Future<List<IsBasvurusuResponse>> basvurulariGetir(String id) => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/is-ilanlari/$id/basvurular'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(IsBasvurusuResponse.jsondan)
            .toList(),
        yedekMesaj: 'Başvurular yüklenemedi.',
      );

  Future<IsBasvurusuResponse> basvuruDurumGuncelle(
    String ilanId,
    String basvuruId,
    IsBasvurusuKarari karar,
  ) =>
      apiIstegi(
        () => _dio.put<Map<String, dynamic>>(
          '/is-ilanlari/$ilanId/basvurular/$basvuruId/durum',
          data: {'durum': karar.deger},
        ),
        cozumle: (veri) => IsBasvurusuResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Başvuru durumu güncellenemedi.',
      );

  Future<List<BasvurumResponse>> basvurularim() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/is-ilanlari/basvurularim'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(BasvurumResponse.jsondan)
            .toList(),
        yedekMesaj: 'Başvurularınız yüklenemedi.',
      );
}

final isIlaniApiProvider = Provider<IsIlaniApi>((ref) => IsIlaniApi(ref.watch(apiClientProvider)));
