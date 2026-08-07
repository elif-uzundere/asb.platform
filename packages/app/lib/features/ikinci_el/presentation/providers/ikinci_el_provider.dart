import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ikinci_el_api.dart';
import '../../domain/ikinci_el_ilan.dart';

/// Backend'den gerçek ikinci el ilanlarını getirir.
///
/// GET /ikinci-el-pazar
final ikinciElIlanlariProvider =
    FutureProvider<List<IkinciElIlan>>((ref) async {
  final api = ref.watch(ikinciElApiProvider);

  return api.ilanlariGetir();
});

/// Favoriye alınan ilanların id'lerini tutar.
///
/// Bu kısım şimdilik cihaz belleğinde çalışır.
/// Backend'e bağlı değildir.
final favoriIlanlarProvider =
    StateNotifierProvider<FavoriIlanlarNotifier, Set<String>>(
  (ref) {
    return FavoriIlanlarNotifier();
  },
);

class FavoriIlanlarNotifier
    extends StateNotifier<Set<String>> {
  FavoriIlanlarNotifier()
      : super(<String>{});

  void favoriDegistir(String ilanId) {
    final yeniFavoriler =
        Set<String>.from(state);

    if (yeniFavoriler.contains(ilanId)) {
      yeniFavoriler.remove(ilanId);
    } else {
      yeniFavoriler.add(ilanId);
    }

    state = yeniFavoriler;
  }

  bool favorideMi(String ilanId) {
    return state.contains(ilanId);
  }

  void favorilerdenKaldir(String ilanId) {
    final yeniFavoriler =
        Set<String>.from(state);

    yeniFavoriler.remove(ilanId);

    state = yeniFavoriler;
  }

  void tumFavorileriTemizle() {
    state = <String>{};
  }
}

/// Sadece favoriye alınmış ilanları döndürür.
///
/// Ana ilan listesi artık FutureProvider olduğu için
/// favori listesi de AsyncValue döndürür.
final favorilenenIlanlarProvider =
    Provider<AsyncValue<List<IkinciElIlan>>>((ref) {
  final ilanlarAsync =
      ref.watch(ikinciElIlanlariProvider);

  final favoriIlanIdleri =
      ref.watch(favoriIlanlarProvider);

  return ilanlarAsync.whenData(
    (ilanlar) {
      return ilanlar.where((ilan) {
        return favoriIlanIdleri.contains(
          ilan.id,
        );
      }).toList();
    },
  );
});