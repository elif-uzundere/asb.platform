import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/is_ilani_modelleri.dart';
import '../../data/is_ilani_api.dart';
import 'is_ilani_basvurulari_durumu.dart';

class IsBasvurusuDurumGuncelleNotifier extends FormNotifier {
  IsBasvurusuDurumGuncelleNotifier(this._ref);

  final Ref _ref;

  Future<void> guncelle(String ilanId, String basvuruId, IsBasvurusuKarari karar) {
    return calistir(() async {
      await _ref.read(isIlaniApiProvider).basvuruDurumGuncelle(ilanId, basvuruId, karar);
      _ref.invalidate(isIlaniBasvurulariProvider(ilanId));
    });
  }
}

final isBasvurusuDurumGuncelleNotifierProvider =
    StateNotifierProvider.autoDispose<IsBasvurusuDurumGuncelleNotifier, IslemDurumu>(
  IsBasvurusuDurumGuncelleNotifier.new,
);
