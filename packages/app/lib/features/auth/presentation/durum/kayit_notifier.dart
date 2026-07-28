// Kayıt formunun iş mantığı.
//
// ÖNEMLİ: Burada bilinçli olarak `authProvider` kullanılmıyor — kayıt başarılı
// olsa bile oturum AÇILMIYOR, kullanıcı /giris'e yönlendirilip elle giriş
// yapıyor (US-001 sapması, docs/CLAUDE.md'de loglu). Kuralın kod içindeki yeri
// burasıdır; ekran bunu bilmek zorunda değil.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/auth_modelleri.dart';
import '../../data/auth_api.dart';
import '../../domain/auth_kurallari.dart';

class KayitNotifier extends FormNotifier {
  KayitNotifier(this._api);

  final AuthApi _api;

  Future<void> gonder({
    required String ad,
    required String soyad,
    required String email,
    required String sifre,
    required String telefon,
  }) {
    return calistir(
      () => _api.kayitOlIstegi(
        RegisterRequest(
          ad: girdiyiTemizle(ad),
          soyad: girdiyiTemizle(soyad),
          email: girdiyiTemizle(email),
          sifre: sifre,
          telefon: opsiyonelGirdi(telefon),
        ),
      ),
    );
  }
}

final kayitNotifierProvider =
    StateNotifierProvider.autoDispose<KayitNotifier, IslemDurumu>(
  (ref) => KayitNotifier(ref.watch(authApiProvider)),
);
