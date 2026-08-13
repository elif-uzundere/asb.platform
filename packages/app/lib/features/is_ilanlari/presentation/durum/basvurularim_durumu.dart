import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/is_ilani_modelleri.dart';
import '../../data/is_ilani_api.dart';

/// Kişiye özel kaynak — sadece giriş yapmış kullanıcının kendi başvuruları.
/// Ekran zaten `authProvider.girisYapildi` kontrolüyle korunuyor (bkz.
/// profil_ekrani.dart deseni), ayrıca burada da guard yazmıyoruz.
final basvurularimProvider = FutureProvider.autoDispose<List<BasvurumResponse>>(
  (ref) => ref.watch(isIlaniApiProvider).basvurularim(),
);
