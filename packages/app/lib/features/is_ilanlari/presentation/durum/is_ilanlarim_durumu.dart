// Profil → İş İlanlarım (firma_yetkilisi görünümü): kendi firmasının açtığı
// tüm ilanlar (aktif + kapalı). `firmaId` token'dan (AktifKullanici) geliyor.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/is_ilani_modelleri.dart';
import '../../../auth/presentation/durum/auth_durumu.dart';
import '../../data/is_ilani_api.dart';

final isIlanlarimProvider = FutureProvider.autoDispose<List<IsIlaniResponse>>((ref) async {
  final firmaId = ref.watch(authProvider).kullanici?.firmaId;
  if (firmaId == null) {
    return const [];
  }
  return ref.watch(isIlaniApiProvider).listele(firmaId: firmaId);
});
