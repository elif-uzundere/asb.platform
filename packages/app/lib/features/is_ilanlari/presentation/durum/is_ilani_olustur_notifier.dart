// destek_talebi_durumu.dart'taki DestekTalebiOlusturNotifier ile birebir
// aynı desen: FormNotifier + başarı sonrası listeyi invalidate.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/is_ilani_modelleri.dart';
import '../../data/is_ilani_api.dart';
import 'is_ilani_liste_durumu.dart';

class IsIlaniOlusturNotifier extends FormNotifier {
  IsIlaniOlusturNotifier(this._ref);

  final Ref _ref;

  Future<void> gonder({required String baslik, required String aciklama, String? konum}) {
    return calistir(() async {
      await _ref.read(isIlaniApiProvider).olustur(
            IsIlaniOlusturRequest(baslik: baslik, aciklama: aciklama, konum: konum),
          );
      // Yeni ilan listeye düşsün diye tazele.
      _ref.invalidate(isIlanlariListesiProvider);
    });
  }
}

final isIlaniOlusturNotifierProvider =
    StateNotifierProvider.autoDispose<IsIlaniOlusturNotifier, IslemDurumu>(
  IsIlaniOlusturNotifier.new,
);
