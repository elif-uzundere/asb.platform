import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/cookzone_modelleri.dart';
import '../../data/cookzone_api.dart';

final cookzoneIsletmelerProvider = FutureProvider.autoDispose<List<CookzoneIsletmeResponse>>(
  (ref) => ref.watch(cookzoneApiProvider).isletmeler(),
);

/// `firma_detay_durumu.dart` ile aynı desen — deep-link güvenliği için
/// listeden taşınan nesneyle değil, her zaman taze veriyle çalışır.
final cookzoneIsletmeDetayProvider = FutureProvider.autoDispose.family<CookzoneIsletmeResponse, String>(
  (ref, id) => ref.watch(cookzoneApiProvider).isletmeDetay(id),
);
