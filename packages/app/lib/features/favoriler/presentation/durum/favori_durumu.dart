// Bir türdeki (İkinci El/Firma/İş İlanı) favorilenmiş hedeflerin id kümesi.
// Giriş yapılmamışsa backend'e hiç sorulmuyor — boş küme döner (misafir
// kullanıcı listeleri gezebilir, sadece favorileyemez).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/favori_modelleri.dart';
import '../../../auth/presentation/durum/auth_durumu.dart';
import '../../data/favori_api.dart';

final favorilerimProvider =
    FutureProvider.autoDispose.family<Set<String>, FavoriHedefTuru>((ref, tur) async {
  final girisYapildi = ref.watch(authProvider).girisYapildi;
  if (!girisYapildi) return const {};
  return ref.watch(favoriApiProvider).favorilerimGetir(tur);
});

/// Tek bir hedefin favoride olup olmadığını okumak için — kalp ikonunun
/// dolu/boş kararı burada.
final favorideMiProvider =
    Provider.autoDispose.family<bool, ({FavoriHedefTuru tur, String hedefId})>((ref, parametre) {
  final favoriler = ref.watch(favorilerimProvider(parametre.tur));
  return favoriler.valueOrNull?.contains(parametre.hedefId) ?? false;
});

/// Kalp butonuna basınca çağrılır — backend'e toggle isteği atar, sonra
/// ilgili türün favori listesini geçersiz kılıp yeniden çektirir.
class FavoriToggleNotifier extends StateNotifier<bool> {
  FavoriToggleNotifier(this._ref) : super(false);

  final Ref _ref;

  Future<void> degistir(FavoriHedefTuru tur, String hedefId) async {
    if (state) return; // çift tıklamayı yok say
    state = true;
    try {
      await _ref.read(favoriApiProvider).durumDegistir(tur, hedefId);
      _ref.invalidate(favorilerimProvider(tur));
    } finally {
      state = false;
    }
  }
}

final favoriToggleNotifierProvider =
    StateNotifierProvider.autoDispose<FavoriToggleNotifier, bool>(FavoriToggleNotifier.new);
