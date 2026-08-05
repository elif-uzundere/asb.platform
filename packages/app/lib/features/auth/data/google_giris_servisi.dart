// google_sign_in paketinin (yan etkili, platform I/O) tek dokunduğu yer.
// Notifier bu paketi DOĞRUDAN import etmez — ekranlar/durum katmanı sadece
// bu servisin metotlarını bilir (bkz. YENI-MODUL-REHBERI.md "data/ katmanı"
// kuralı, diğer *_servisi.dart dosyalarıyla AYNI desen).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleGirisServisi {
  const GoogleGirisServisi();

  GoogleSignIn get _instance => GoogleSignIn.instance;

  /// Uygulama açılışında BİR KERE çağrılmalı. Platforma göre HANGİ
  /// parametrenin doldurulacağı çağıran tarafın (google_giris_notifier.dart)
  /// sorumluluğu — web'de `serverClientId` YASAK (plugin assert ediyor),
  /// mobilde ise backend doğrulaması için gerekli.
  Future<void> hazirla({required String? clientId, required String? serverClientId}) =>
      _instance.initialize(clientId: clientId, serverClientId: serverClientId);

  /// Giriş/çıkış sonuçlarının tek kaynağı — web'de "renderButton" tıklanınca,
  /// mobilde `tetikle()` çağrılınca hep buradan olay gelir.
  Stream<GoogleSignInAuthenticationEvent> get olaylar => _instance.authenticationEvents;

  /// Web'de false döner — Google Identity Services web'de kendi düğmesinin
  /// tıklanmasını zorunlu kılıyor, programatik tetikleme YOK (tarayıcı
  /// güvenlik kısıtı, plugin kusuru değil).
  bool get dogrudanTetiklenebilir => _instance.supportsAuthenticate();

  /// Sadece [dogrudanTetiklenebilir] true iken (mobil) çağrılır.
  Future<void> tetikle() => _instance.authenticate();

  Future<void> cikisYap() => _instance.signOut();
}

final googleGirisServisiProvider =
    Provider<GoogleGirisServisi>((ref) => const GoogleGirisServisi());
