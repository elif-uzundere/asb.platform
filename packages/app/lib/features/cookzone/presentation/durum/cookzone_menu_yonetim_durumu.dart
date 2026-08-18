// cookzone_yetkilisi'nin menü yönetim ekranı için durum yönetimi — Palet
// Tesisi'ndeki palet_yonetim_notifier.dart ile aynı desen.

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/cookzone_modelleri.dart';
import '../../data/cookzone_api.dart';

final cookzoneMenuYonetimProvider =
    FutureProvider.autoDispose<List<CookzoneMenuOgesiResponse>>((ref) async {
  final api = ref.watch(cookzoneApiProvider);
  return api.menuOgeleriTumunuGetir();
});

class CookzoneMenuOgesiOlusturNotifier extends FormNotifier {
  CookzoneMenuOgesiOlusturNotifier(this._ref);

  final Ref _ref;

  Future<void> olustur({
    required String ad,
    String? aciklama,
    required num fiyat,
    required String kategori,
    Uint8List? gorselBaytlari,
    String? gorselDosyaAdi,
  }) {
    return calistir(() async {
      await _ref.read(cookzoneApiProvider).menuOgesiOlustur(
            ad: ad,
            aciklama: aciklama,
            fiyat: fiyat,
            kategori: kategori,
            gorselBaytlari: gorselBaytlari,
            gorselDosyaAdi: gorselDosyaAdi,
          );
      _ref.invalidate(cookzoneMenuYonetimProvider);
    });
  }
}

final cookzoneMenuOgesiOlusturNotifierProvider =
    StateNotifierProvider.autoDispose<CookzoneMenuOgesiOlusturNotifier, IslemDurumu>(
  CookzoneMenuOgesiOlusturNotifier.new,
);

class CookzoneMenuOgesiGuncelleNotifier extends FormNotifier {
  CookzoneMenuOgesiGuncelleNotifier(this._ref);

  final Ref _ref;

  Future<void> guncelle(
    String id, {
    String? ad,
    String? aciklama,
    num? fiyat,
    String? kategori,
    bool? aktif,
    Uint8List? gorselBaytlari,
    String? gorselDosyaAdi,
  }) {
    return calistir(() async {
      await _ref.read(cookzoneApiProvider).menuOgesiGuncelle(
            id,
            ad: ad,
            aciklama: aciklama,
            fiyat: fiyat,
            kategori: kategori,
            aktif: aktif,
            gorselBaytlari: gorselBaytlari,
            gorselDosyaAdi: gorselDosyaAdi,
          );
      _ref.invalidate(cookzoneMenuYonetimProvider);
    });
  }
}

final cookzoneMenuOgesiGuncelleNotifierProvider =
    StateNotifierProvider.autoDispose<CookzoneMenuOgesiGuncelleNotifier, IslemDurumu>(
  CookzoneMenuOgesiGuncelleNotifier.new,
);

class CookzoneMenuOgesiSilNotifier extends FormNotifier {
  CookzoneMenuOgesiSilNotifier(this._ref);

  final Ref _ref;

  Future<void> sil(String id) {
    return calistir(() async {
      await _ref.read(cookzoneApiProvider).menuOgesiSil(id);
      _ref.invalidate(cookzoneMenuYonetimProvider);
    });
  }
}

final cookzoneMenuOgesiSilNotifierProvider =
    StateNotifierProvider.autoDispose<CookzoneMenuOgesiSilNotifier, IslemDurumu>(
  CookzoneMenuOgesiSilNotifier.new,
);
