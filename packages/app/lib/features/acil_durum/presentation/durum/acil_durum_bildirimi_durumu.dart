import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../data/acil_durum_api.dart';
import '../../domain/acil_durum_bildirimi.dart';

final bildirimlerimProvider = FutureProvider.autoDispose<List<AcilDurumBildirimiResponse>>(
  (ref) => ref.watch(acilDurumApiProvider).bildirimlerimGetir(),
);

class AcilDurumBildirimiNotifier extends FormNotifier {
  AcilDurumBildirimiNotifier(this._ref);

  final Ref _ref;

  Future<void> gonder(AcilDurumTuru tur, String aciklama) {
    return calistir(() async {
      await _ref.read(acilDurumApiProvider).bildirimOlustur(tur, aciklama);
      _ref.invalidate(bildirimlerimProvider);
    });
  }
}

final acilDurumBildirimiNotifierProvider =
    StateNotifierProvider.autoDispose<AcilDurumBildirimiNotifier, IslemDurumu>(
  AcilDurumBildirimiNotifier.new,
);
