// Firma detay ekranının state'i. FutureProvider.family kullanılıyor çünkü bu
// salt bir okuma (yazma/gönderme yok) ve parametre olarak firma id'sine
// ihtiyaç var — FormNotifier burada uygun değil, o form gönderimi için.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/firma_modelleri.dart';
import '../../data/firma_api.dart';

final firmaDetayProvider =
    FutureProvider.autoDispose.family<FirmaResponse, String>(
  (ref, id) => ref.watch(firmaApiProvider).detay(id),
);
