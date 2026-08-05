// E-posta Değiştir formunun iş mantığı. Başarıda auth durumundaki e-postayı
// da güncelliyor — yoksa Profil ekranı eski e-postayı göstermeye devam eder.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/auth_modelleri.dart';
import '../../data/auth_api.dart';
import 'auth_durumu.dart';

class EpostaDegistirNotifier extends FormNotifier {
  EpostaDegistirNotifier(this._ref);

  final Ref _ref;

  Future<void> gonder({required String yeniEposta, required String mevcutSifre}) {
    return calistir(() async {
      await _ref.read(authApiProvider).epostaDegistirIstegi(
            EpostaDegistirRequest(yeniEposta: yeniEposta, mevcutSifre: mevcutSifre),
          );
      final mevcutKullanici = _ref.read(authProvider).kullanici;
      if (mevcutKullanici != null) {
        await _ref
            .read(authProvider.notifier)
            .kullaniciyiGuncelle(mevcutKullanici.kopyala(email: yeniEposta));
      }
    });
  }
}

final epostaDegistirNotifierProvider =
    StateNotifierProvider.autoDispose<EpostaDegistirNotifier, IslemDurumu>(
  EpostaDegistirNotifier.new,
);
