// Sepet, backend'e hiç dokunmayan SAF yerel UI state'i — sipariş
// oluşturulana kadar sadece bellekte tutulur, bu yüzden FormNotifier değil
// düz bir StateNotifier. `isletmeId`ye göre `.family` — kullanıcı farklı bir
// işletmenin menüsüne geçerse eski sepet karışmasın diye.

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SepetNotifier extends StateNotifier<Map<String, int>> {
  SepetNotifier() : super(const {});

  void ekle(String menuOgesiId) {
    state = {...state, menuOgesiId: (state[menuOgesiId] ?? 0) + 1};
  }

  void azalt(String menuOgesiId) {
    final mevcutAdet = state[menuOgesiId] ?? 0;
    if (mevcutAdet <= 1) {
      final yeniState = {...state}..remove(menuOgesiId);
      state = yeniState;
      return;
    }
    state = {...state, menuOgesiId: mevcutAdet - 1};
  }

  void temizle() {
    state = const {};
  }
}

final sepetNotifierProvider =
    StateNotifierProvider.autoDispose.family<SepetNotifier, Map<String, int>, String>(
  (ref, isletmeId) => SepetNotifier(),
);
