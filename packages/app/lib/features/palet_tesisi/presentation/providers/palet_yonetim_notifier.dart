import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../data/palet_tesisi_api.dart';
import 'palet_tesisi_provider.dart';

class PaletOlusturNotifier extends FormNotifier {
  PaletOlusturNotifier(this._ref);

  final Ref _ref;

  Future<void> olustur({
    required String ad,
    String? aciklama,
    String? olcu,
    Uint8List? gorselBaytlari,
    String? gorselDosyaAdi,
  }) {
    return calistir(() async {
      await _ref.read(paletTesisiApiProvider).paletOlustur(
            ad: ad,
            aciklama: aciklama,
            olcu: olcu,
            gorselBaytlari: gorselBaytlari,
            gorselDosyaAdi: gorselDosyaAdi,
          );
      _ref.invalidate(tumPaletlerProvider);
      _ref.invalidate(paletlerProvider);
    });
  }
}

final paletOlusturNotifierProvider =
    StateNotifierProvider.autoDispose<PaletOlusturNotifier, IslemDurumu>(
  PaletOlusturNotifier.new,
);

class PaletGuncelleNotifier extends FormNotifier {
  PaletGuncelleNotifier(this._ref);

  final Ref _ref;

  Future<void> guncelle(
    String id, {
    String? ad,
    String? aciklama,
    String? olcu,
    Uint8List? gorselBaytlari,
    String? gorselDosyaAdi,
  }) {
    return calistir(() async {
      await _ref.read(paletTesisiApiProvider).paletGuncelle(
            id,
            ad: ad,
            aciklama: aciklama,
            olcu: olcu,
            gorselBaytlari: gorselBaytlari,
            gorselDosyaAdi: gorselDosyaAdi,
          );
      _ref.invalidate(tumPaletlerProvider);
      _ref.invalidate(paletlerProvider);
    });
  }
}

final paletGuncelleNotifierProvider =
    StateNotifierProvider.autoDispose<PaletGuncelleNotifier, IslemDurumu>(
  PaletGuncelleNotifier.new,
);
