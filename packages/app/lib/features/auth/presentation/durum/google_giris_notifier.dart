// Google ile giriş akışının durumu. Diğer FormNotifier'lardan FARKLI: bu
// notifier bir metot çağrısıyla değil, google_sign_in'in kendi olay
// akışıyla (authenticationEvents) tetikleniyor — çünkü web'de giriş
// Google'ın kendi düğmesinden başlıyor, bizim bir onPressed'imiz yok
// (bkz. widgets/google_giris_dugmesi_web.dart).

import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/google_auth_yapilandirmasi.dart';
import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/auth_modelleri.dart';
import '../../data/auth_api.dart';
import '../../data/google_giris_servisi.dart';
import 'auth_durumu.dart';

class GoogleGirisNotifier extends FormNotifier {
  GoogleGirisNotifier(this._ref) {
    unawaited(_hazirla());
  }

  final Ref _ref;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _abonelik;
  bool _hazir = false;

  bool get dogrudanTetiklenebilir => _ref.read(googleGirisServisiProvider).dogrudanTetiklenebilir;

  Future<void> _hazirla() async {
    final servisi = _ref.read(googleGirisServisiProvider);
    try {
      // google_sign_in_web'in kendi assert'i: web'de serverClientId YASAK
      // (sadece clientId kullanılır). Mobilde ise tam tersi — backend'in
      // token'ı doğrulayabilmesi için serverClientId (Web Client ID) şart,
      // clientId ise native config'ten (paket adı + SHA-1) otomatik gelir.
      if (kIsWeb) {
        await servisi.hazirla(clientId: googleWebClientId, serverClientId: null);
      } else {
        await servisi.hazirla(clientId: null, serverClientId: googleWebClientId);
      }
    } catch (hata) {
      // Kurulum başarısız olursa buton görünse bile hiç işe yaramaz —
      // sessizce yutmak yerine kullanıcıya söylüyoruz.
      if (mounted) state = IslemHatali('Google girişi başlatılamadı: $hata');
    }
    _hazir = true;
    _abonelik = servisi.olaylar.listen(_olayGeldi, onError: _hataGeldi);
  }

  Future<void> _olayGeldi(GoogleSignInAuthenticationEvent olay) async {
    if (olay is! GoogleSignInAuthenticationEventSignIn) return;

    final idToken = olay.user.authentication.idToken;
    if (idToken == null) {
      if (mounted) state = const IslemHatali('Google girişi tamamlanamadı.');
      return;
    }

    await calistir(() async {
      final sonuc = await _ref
          .read(authApiProvider)
          .googleIleGirisIstegi(GoogleGirisRequest(idToken: idToken));
      await _ref.read(authProvider.notifier).oturumuKaydet(sonuc);
    });
  }

  void _hataGeldi(Object hata) {
    if (mounted) state = IslemHatali('Google girişi başarısız: $hata');
  }

  /// Sadece [dogrudanTetiklenebilir] true iken (mobil) çağrılır — web'de
  /// tıklama zaten Google'ın kendi düğmesi üzerinden [_olayGeldi]'ye düşer.
  Future<void> tetikle() async {
    if (!_hazir) return;
    try {
      await _ref.read(googleGirisServisiProvider).tetikle();
    } on GoogleSignInException catch (hata) {
      // Kullanıcı Google penceresini kapattıysa hata GÖSTERME — bu bir
      // hata değil, vazgeçme.
      if (hata.code == GoogleSignInExceptionCode.canceled) return;
      if (mounted) state = IslemHatali('Google girişi başarısız: ${hata.description}');
    }
  }

  @override
  void dispose() {
    unawaited(_abonelik?.cancel());
    super.dispose();
  }
}

final googleGirisNotifierProvider =
    StateNotifierProvider.autoDispose<GoogleGirisNotifier, IslemDurumu>(
  GoogleGirisNotifier.new,
);
