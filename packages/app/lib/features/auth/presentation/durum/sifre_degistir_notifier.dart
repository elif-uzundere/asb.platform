// Şifre Değiştir formunun iş mantığı — giris_notifier.dart ile AYNI desen.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/auth_modelleri.dart';
import '../../data/auth_api.dart';

class SifreDegistirNotifier extends FormNotifier {
  SifreDegistirNotifier(this._ref);

  final Ref _ref;

  Future<void> gonder({required String mevcutSifre, required String yeniSifre}) {
    return calistir(
      () => _ref.read(authApiProvider).sifreDegistirIstegi(
            SifreDegistirRequest(mevcutSifre: mevcutSifre, yeniSifre: yeniSifre),
          ),
    );
  }
}

final sifreDegistirNotifierProvider =
    StateNotifierProvider.autoDispose<SifreDegistirNotifier, IslemDurumu>(
  SifreDegistirNotifier.new,
);
