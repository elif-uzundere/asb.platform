import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/cookzone_modelleri.dart';
import '../../data/cookzone_api.dart';

/// Sadece işletme sahibi cookzone_yetkilisi çağırabilir — backend 403 ile
/// koruyor, bu ekran zaten role göre gizleniyor.
final cookzoneIsletmeSiparisleriProvider = FutureProvider.autoDispose<List<CookzoneSiparisYonetimResponse>>(
  (ref) => ref.watch(cookzoneApiProvider).isletmeSiparisleri(),
);
