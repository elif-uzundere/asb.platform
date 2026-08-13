import 'dart:typed_data';

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

  /// Palet Tesisi yönetim ekranı — pasif olanlar dahil hepsi.
  Future<List<Palet>> tumPaletleriGetir() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/palet-tesisi/paletler/tumu'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(Palet.jsondan)
            .toList(),
        yedekMesaj: 'Paletler yüklenemedi.',
      );

  /// `gorselBaytlari`/`gorselDosyaAdi` opsiyonel — görselsiz de palet
  /// çeşidi eklenebilir. Bayt tabanlı, İş İlanları'ndaki CV yüklemeyle aynı
  /// gerekçe (web'de gerçek dosya yolu yok).
  Future<Palet> paletOlustur({
    required String ad,
    String? aciklama,
    String? olcu,
    Uint8List? gorselBaytlari,
    String? gorselDosyaAdi,
  }) =>
      apiIstegi(
        () => _dio.post<Map<String, dynamic>>(
          '/palet-tesisi/paletler',
          data: FormData.fromMap({
            'ad': ad,
            if (aciklama != null && aciklama.isNotEmpty) 'aciklama': aciklama,
            if (olcu != null && olcu.isNotEmpty) 'olcu': olcu,
            if (gorselBaytlari != null)
              'gorsel': MultipartFile.fromBytes(gorselBaytlari, filename: gorselDosyaAdi ?? 'gorsel.jpg'),
          }),
        ),
        cozumle: (veri) => Palet.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Palet çeşidi oluşturulamadı.',
      );

  /// Kısmi güncelleme — sadece dolu alanlar gönderilir. Mevcut (görselsiz)
  /// bir palete SONRADAN görsel eklemek için de bu kullanılır.
  Future<Palet> paletGuncelle(
    String id, {
    String? ad,
    String? aciklama,
    String? olcu,
    Uint8List? gorselBaytlari,
    String? gorselDosyaAdi,
  }) =>
      apiIstegi(
        () => _dio.put<Map<String, dynamic>>(
          '/palet-tesisi/paletler/$id',
          data: FormData.fromMap({
            if (ad != null && ad.isNotEmpty) 'ad': ad,
            if (aciklama != null && aciklama.isNotEmpty) 'aciklama': aciklama,
            if (olcu != null && olcu.isNotEmpty) 'olcu': olcu,
            if (gorselBaytlari != null)
              'gorsel': MultipartFile.fromBytes(gorselBaytlari, filename: gorselDosyaAdi ?? 'gorsel.jpg'),
          }),
        ),
        cozumle: (veri) => Palet.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Palet çeşidi güncellenemedi.',
      );
}

final paletTesisiApiProvider =
    Provider<PaletTesisiApi>(
  (ref) {
    return PaletTesisiApi(
      ref.watch(apiClientProvider),
    );
  },
);