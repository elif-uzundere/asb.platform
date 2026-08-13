import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../data/is_ilani_api.dart';
import 'is_ilani_detay_durumu.dart';
import 'is_ilani_liste_durumu.dart';

class IsIlaniKapatNotifier extends FormNotifier {
  IsIlaniKapatNotifier(this._ref);

  final Ref _ref;

  Future<void> kapat(String ilanId) {
    return calistir(() async {
      await _ref.read(isIlaniApiProvider).kapat(ilanId);
      // Detay ekranı "kapalı" durumunu göstersin, herkese açık liste de
      // kapanan ilanı düşürsün.
      _ref.invalidate(isIlaniDetayProvider(ilanId));
      _ref.invalidate(isIlanlariListesiProvider);
    });
  }
}

final isIlaniKapatNotifierProvider =
    StateNotifierProvider.autoDispose<IsIlaniKapatNotifier, IslemDurumu>(
  IsIlaniKapatNotifier.new,
);
