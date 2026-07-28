// Giriş formunun iş mantığı. Ekran sadece metin alanlarını tutar ve
// durumu dinler; girdi temizleme, istek atma ve hata yakalama burada.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/auth_modelleri.dart';
import '../../domain/auth_kurallari.dart';
import 'auth_durumu.dart';

class GirisNotifier extends FormNotifier {
  GirisNotifier(this._ref);

  final Ref _ref;

  Future<void> gonder({
    required String email,
    required String sifre,
    required bool beniHatirla,
  }) {
    return calistir(
      () => _ref.read(authProvider.notifier).girisYap(
            LoginRequest(
              email: girdiyiTemizle(email),
              sifre: sifre,
              beniHatirla: beniHatirla,
            ),
          ),
    );
  }
}

final girisNotifierProvider =
    StateNotifierProvider.autoDispose<GirisNotifier, IslemDurumu>(
  GirisNotifier.new,
);
