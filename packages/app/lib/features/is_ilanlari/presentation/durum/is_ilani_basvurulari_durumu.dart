import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/is_ilani_modelleri.dart';
import '../../data/is_ilani_api.dart';

/// Sadece ilan sahibi firma yetkilisi çağırabilir — backend 403 ile
/// koruyor (bkz. IsIlaniController.basvurulariGetir), bu ekran zaten
/// is_ilani_kurallari.dart → ilanSahibiMi() ile gizleniyor.
final isIlaniBasvurulariProvider = FutureProvider.autoDispose.family<List<IsBasvurusuResponse>, String>(
  (ref, ilanId) => ref.watch(isIlaniApiProvider).basvurulariGetir(ilanId),
);
