// GET uçları katalog modeli (girişsiz de çalışır), sipariş verme/yönetme
// kişiye özel — dio interceptor token'ı zaten ekliyor.

import 'dart:typed_data';

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

  // ── Menü yönetimi — cookzone_yetkilisi tarafı ───────────────────────────

  /// Pasif dahil TÜMÜ — yönetim ekranı için (Palet Tesisi'ndeki
  /// `tumPaletleriGetir` ile aynı gerekçe).
  Future<List<CookzoneMenuOgesiResponse>> menuOgeleriTumunuGetir() => apiIstegi(
        () => _dio.get<Map<String, dynamic>>('/cookzone/menu/tumu'),
        cozumle: (veri) => (veri as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(CookzoneMenuOgesiResponse.jsondan)
            .toList(),
        yedekMesaj: 'Menü öğeleri yüklenemedi.',
      );

  /// `gorselBaytlari`/`gorselDosyaAdi` opsiyonel — Palet Tesisi'ndeki
  /// yüklemeyle aynı desen (bayt tabanlı, web'de gerçek dosya yolu yok).
  Future<CookzoneMenuOgesiResponse> menuOgesiOlustur({
    required String ad,
    String? aciklama,
    required num fiyat,
    required String kategori,
    Uint8List? gorselBaytlari,
    String? gorselDosyaAdi,
  }) =>
      apiIstegi(
        () => _dio.post<Map<String, dynamic>>(
          '/cookzone/menu',
          data: FormData.fromMap({
            'ad': ad,
            if (aciklama != null && aciklama.isNotEmpty) 'aciklama': aciklama,
            'fiyat': fiyat,
            'kategori': kategori,
            if (gorselBaytlari != null)
              'gorsel': MultipartFile.fromBytes(gorselBaytlari, filename: gorselDosyaAdi ?? 'gorsel.jpg'),
          }),
        ),
        cozumle: (veri) => CookzoneMenuOgesiResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Menü öğesi oluşturulamadı.',
      );

  Future<CookzoneMenuOgesiResponse> menuOgesiGuncelle(
    String id, {
    String? ad,
    String? aciklama,
    num? fiyat,
    String? kategori,
    bool? aktif,
    Uint8List? gorselBaytlari,
    String? gorselDosyaAdi,
  }) =>
      apiIstegi(
        () => _dio.put<Map<String, dynamic>>(
          '/cookzone/menu/$id',
          data: FormData.fromMap({
            if (ad != null && ad.isNotEmpty) 'ad': ad,
            if (aciklama != null && aciklama.isNotEmpty) 'aciklama': aciklama,
            'fiyat': ?fiyat,
            if (kategori != null && kategori.isNotEmpty) 'kategori': kategori,
            if (aktif != null) 'aktif': aktif.toString(),
            if (gorselBaytlari != null)
              'gorsel': MultipartFile.fromBytes(gorselBaytlari, filename: gorselDosyaAdi ?? 'gorsel.jpg'),
          }),
        ),
        cozumle: (veri) => CookzoneMenuOgesiResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Menü öğesi güncellenemedi.',
      );

  /// Soft-delete (backend `aktif = false` yapar, gerçek satırı silmez —
  /// geçmiş siparişler bu öğeye FK ile bağlı).
  Future<void> menuOgesiSil(String id) => apiIstegi(
        () => _dio.delete<Map<String, dynamic>>('/cookzone/menu/$id'),
        cozumle: (_) {},
        yedekMesaj: 'Menü öğesi silinemedi.',
      );
}

final cookzoneApiProvider = Provider<CookzoneApi>((ref) => CookzoneApi(ref.watch(apiClientProvider)));
