import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';
import '../domain/ikinci_el_ilan.dart';

class IkinciElFotografi {
  const IkinciElFotografi({required this.baytlar, required this.dosyaAdi});

  final Uint8List baytlar;
  final String dosyaAdi;
}

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
  /// Fotoğraflar bayt tabanlı — Palet Tesisi'ndeki gerçek dosya yüklemeyle
  /// aynı gerekçe (web'de gerçek dosya yolu yok). En az bir fotoğraf zorunlu
  /// (backend de aynı kuralı uyguluyor).
  ///
  /// POST /ikinci-el-pazar (multipart/form-data)
  Future<IkinciElIlan> ilanOlustur({
    required String baslik,
    required String aciklama,
    required double fiyat,
    required String kategori,
    required String urunDurumu,
    required String iletisimTelefonu,
    required List<IkinciElFotografi> fotograflar,
  }) {
    return apiIstegi(
      () => _dio.post<Map<String, dynamic>>(
        '/ikinci-el-pazar',
        data: FormData.fromMap({
          'baslik': baslik,
          'aciklama': aciklama,
          'fiyat': fiyat,
          'kategori': kategori,
          'urunDurumu': urunDurumu,
          'iletisimTelefonu': iletisimTelefonu,
          'fotograflar': fotograflar
              .map(
                (f) => MultipartFile.fromBytes(
                  f.baytlar,
                  filename: f.dosyaAdi,
                ),
              )
              .toList(),
        }),
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