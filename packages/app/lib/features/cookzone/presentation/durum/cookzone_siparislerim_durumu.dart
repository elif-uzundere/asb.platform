import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/cookzone_modelleri.dart';
import '../../data/cookzone_api.dart';

final cookzoneSiparislerimProvider = FutureProvider.autoDispose<List<CookzoneSiparisResponse>>(
  (ref) => ref.watch(cookzoneApiProvider).siparislerim(),
);
