import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/is_ilani_modelleri.dart';
import '../../data/is_ilani_api.dart';

/// firma_detay_durumu.dart ile aynı desen: id parametreli, deep-link
/// güvenliği için her zaman `GET /is-ilanlari/{id}` ile taze veri çeker.
final isIlaniDetayProvider = FutureProvider.autoDispose.family<IsIlaniResponse, String>(
  (ref, id) => ref.watch(isIlaniApiProvider).detay(id),
);
