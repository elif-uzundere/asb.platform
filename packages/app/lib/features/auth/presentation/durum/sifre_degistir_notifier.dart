// Şifre Değiştir formunun iş mantığı — giris_notifier.dart ile AYNI desen.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/auth_modelleri.dart';
import '../../../../core/network/api_hata.dart';
import '../../data/auth_api.dart';
import '../../domain/auth_kurallari.dart';

class SifreDegistirNotifier extends FormNotifier {
  SifreDegistirNotifier(this._ref);

  final Ref _ref;

  Future<void> gonder({
    required String mevcutSifre,
    required String yeniSifre,
    required String yeniSifreTekrar,
  }) {
    return calistir(() async {
      // Ağa hiç çıkmadan, tek yerde tanımlı kuralla kontrol ediliyor —
      // eşleşmiyorsa ApiHata fırlatılıyor ki calistir()'in zaten bildiği
      // hata gösterme akışı (islemGeriBildirimi) aynen çalışsın.
      if (!sifrelerEslesiyor(yeniSifre, yeniSifreTekrar)) {
        throw const ApiHata('Yeni şifreler eşleşmiyor.');
      }
      await _ref.read(authApiProvider).sifreDegistirIstegi(
            SifreDegistirRequest(mevcutSifre: mevcutSifre, yeniSifre: yeniSifre),
          );
    });
  }
}

final sifreDegistirNotifierProvider =
    StateNotifierProvider.autoDispose<SifreDegistirNotifier, IslemDurumu>(
  SifreDegistirNotifier.new,
);
