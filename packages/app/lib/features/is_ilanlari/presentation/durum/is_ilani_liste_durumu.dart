// Firma modülündeki arama/sektör filtresinin aksine iş ilanları listesinde
// (US-006) bir filtre gereksinimi yok — bu yüzden firma_liste_durumu.dart'taki
// elle StateNotifier yerine düz bir FutureProvider yeterli.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/is_ilani_modelleri.dart';
import '../../data/is_ilani_api.dart';

final isIlanlariListesiProvider = FutureProvider.autoDispose<List<IsIlaniResponse>>(
  (ref) => ref.watch(isIlaniApiProvider).listele(),
);
