import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/cookzone_modelleri.dart';
import '../../data/cookzone_api.dart';
import 'cookzone_siparislerim_durumu.dart';
import 'sepet_notifier.dart';

class CookzoneSiparisOlusturNotifier extends FormNotifier {
  CookzoneSiparisOlusturNotifier(this._ref);

  final Ref _ref;

  Future<void> gonder({
    required String isletmeId,
    required DateTime alinmaSaati,
    required Map<String, int> sepet,
  }) {
    return calistir(() async {
      final kalemler = sepet.entries
          .map((girdi) => CookzoneSiparisKalemiRequest(menuOgesiId: girdi.key, adet: girdi.value))
          .toList();
      await _ref.read(cookzoneApiProvider).siparisOlustur(
            CookzoneSiparisOlusturRequest(
              isletmeId: isletmeId,
              alinmaSaati: alinmaSaati.toUtc().toIso8601String(),
              kalemler: kalemler,
            ),
          );
      _ref.read(sepetNotifierProvider(isletmeId).notifier).temizle();
      _ref.invalidate(cookzoneSiparislerimProvider);
    });
  }
}

final cookzoneSiparisOlusturNotifierProvider =
    StateNotifierProvider.autoDispose<CookzoneSiparisOlusturNotifier, IslemDurumu>(
  CookzoneSiparisOlusturNotifier.new,
);
