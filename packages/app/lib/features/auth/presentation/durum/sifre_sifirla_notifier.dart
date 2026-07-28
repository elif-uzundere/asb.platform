// Şifre sıfırlama formunun iş mantığı.
//
// Token e-postadaki linkten (URL parametresi) gelir, kullanıcıya hiç
// gösterilmez. "Token kullanılabilir mi?" kararı domain'deki
// `sifirlamaTokeniGecerli` fonksiyonunda — ekran kendi if'ini yazmaz.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/auth_modelleri.dart';
import '../../data/auth_api.dart';
import '../../domain/auth_kurallari.dart';

class SifreSifirlaNotifier extends FormNotifier {
  SifreSifirlaNotifier(this._api);

  final AuthApi _api;

  Future<void> gonder({
    required String? token,
    required String yeniSifre,
  }) {
    return calistir(
      () => _api.sifreSifirlaIstegi(
        SifreSifirlaRequest(
          token: girdiyiTemizle(token ?? ''),
          yeniSifre: yeniSifre,
        ),
      ),
    );
  }
}

final sifreSifirlaNotifierProvider =
    StateNotifierProvider.autoDispose<SifreSifirlaNotifier, IslemDurumu>(
  (ref) => SifreSifirlaNotifier(ref.watch(authApiProvider)),
);

/// Ekranın "form mu, geçersiz link mesajı mı göstereyim" sorusunun cevabı.
final sifirlamaTokeniGecerliProvider =
    Provider.autoDispose.family<bool, String?>(
  (ref, token) => sifirlamaTokeniGecerli(token),
);
