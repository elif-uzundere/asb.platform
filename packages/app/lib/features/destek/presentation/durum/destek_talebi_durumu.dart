// Taleplerim listesi (salt okuma → FutureProvider) ve Yeni Talep Oluştur
// formu (yazma → FormNotifier) — aynı ayrım duyuru_durumu.dart/
// giris_notifier.dart'takiyle birebir aynı gerekçeyle yapıldı.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/destek_talebi_modelleri.dart';
import '../../data/destek_talebi_api.dart';

final taleplerimProvider = FutureProvider.autoDispose<List<DestekTalebiResponse>>(
  (ref) => ref.watch(destekTalebiApiProvider).listele(),
);

class DestekTalebiOlusturNotifier extends FormNotifier {
  DestekTalebiOlusturNotifier(this._ref);

  final Ref _ref;

  Future<void> gonder({required String baslik, required String aciklama}) {
    return calistir(() async {
      await _ref.read(destekTalebiApiProvider).olustur(
            DestekTalebiOlusturRequest(baslik: baslik, aciklama: aciklama),
          );
      // Yeni talep listeye düşsün diye Taleplerim'i tazele.
      _ref.invalidate(taleplerimProvider);
    });
  }
}

final destekTalebiOlusturNotifierProvider =
    StateNotifierProvider.autoDispose<DestekTalebiOlusturNotifier, IslemDurumu>(
  DestekTalebiOlusturNotifier.new,
);
