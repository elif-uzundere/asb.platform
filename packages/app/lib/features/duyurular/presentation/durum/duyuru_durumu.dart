// Duyuru liste ve detay ekranlarının state'i. İkisi de salt okuma
// (yazma/gönderme yok), bu yüzden FormNotifier değil FutureProvider yeterli
// — bkz. firma_liste_durumu.dart/firma_detay_durumu.dart'taki aynı gerekçe.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/duyuru_modelleri.dart';
import '../../data/duyuru_api.dart';

final duyuruListesiProvider = FutureProvider.autoDispose<List<DuyuruResponse>>(
  (ref) => ref.watch(duyuruApiProvider).listele(),
);

final duyuruDetayProvider =
    FutureProvider.autoDispose.family<DuyuruResponse, String>(
  (ref, id) => ref.watch(duyuruApiProvider).detay(id),
);
