// "Şifremi unuttum" formunun iş mantığı.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/auth_modelleri.dart';
import '../../data/auth_api.dart';
import '../../domain/auth_kurallari.dart';

class SifremiUnuttumNotifier extends FormNotifier {
  SifremiUnuttumNotifier(this._api);

  final AuthApi _api;

  Future<void> gonder({required String email}) {
    return calistir(
      () => _api.sifremiUnuttumIstegi(
        SifremiUnuttumRequest(email: girdiyiTemizle(email)),
      ),
    );
  }
}

final sifremiUnuttumNotifierProvider =
    StateNotifierProvider.autoDispose<SifremiUnuttumNotifier, IslemDurumu>(
  (ref) => SifremiUnuttumNotifier(ref.watch(authApiProvider)),
);
