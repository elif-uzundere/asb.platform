// Kaynak: eski Expo src/core/stores/auth.store.ts (zustand + persist) karşılığı. (silindi — bkz. izlence Ek A)
//
// Bilinçli fark: `kayitOl` burada YOK. Kayıt sonrası otomatik giriş yapılmıyor,
// kullanıcı /giris'e yönlendirilip elle giriş yapıyor (US-001 sapması,
// docs/CLAUDE.md'de loglu). Kayıt akışı bu yüzden ayrı bir notifier'da
// (kayit_notifier.dart) ve oturum durumuna hiç dokunmuyor.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/auth_modelleri.dart';
import '../../../../core/storage/auth_depo.dart';
import '../../data/auth_api.dart';

class AuthDurumu {
  const AuthDurumu({
    this.kullanici,
    this.accessToken,
    this.hazir = false,
  });

  final KullaniciOzet? kullanici;
  final String? accessToken;

  /// Güvenli depodan ilk okuma tamamlandı mı? Tamamlanmadan yönlendirme
  /// yapılırsa oturumu açık kullanıcı bir an /giris'e düşer.
  final bool hazir;

  bool get girisYapildi => accessToken != null && kullanici != null;
}

class AuthNotifier extends StateNotifier<AuthDurumu> {
  AuthNotifier(this._api, this._depo) : super(const AuthDurumu()) {
    _depodanYukle();
  }

  final AuthApi _api;
  final AuthDepo _depo;

  Future<void> _depodanYukle() async {
    final kayit = await _depo.oku();
    if (!mounted) return;
    state = AuthDurumu(
      kullanici: kayit?.kullanici,
      accessToken: kayit?.accessToken,
      hazir: true,
    );
  }

  Future<void> girisYap(LoginRequest dto) async {
    final sonuc = await _api.girisYapIstegi(dto);
    await _depo.yaz(
      AuthKaydi(accessToken: sonuc.accessToken, kullanici: sonuc.kullanici),
    );
    if (!mounted) return;
    state = AuthDurumu(
      kullanici: sonuc.kullanici,
      accessToken: sonuc.accessToken,
      hazir: true,
    );
  }

  Future<void> cikisYap() async {
    await _depo.temizle();
    if (!mounted) return;
    state = const AuthDurumu(hazir: true);
  }

  /// Şifre/E-posta/Profil değiştirme sonrası bellekteki ve depodaki
  /// kullanıcı özetini günceller — tam bir `girisYap` değil, yeniden token
  /// almadan sadece görüntülenen bilgiyi tazeler.
  Future<void> kullaniciyiGuncelle(KullaniciOzet yeni) async {
    final token = state.accessToken;
    if (token == null) return;
    await _depo.yaz(AuthKaydi(accessToken: token, kullanici: yeni));
    if (!mounted) return;
    state = AuthDurumu(kullanici: yeni, accessToken: token, hazir: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthDurumu>(
  (ref) => AuthNotifier(ref.watch(authApiProvider), ref.watch(authDepoProvider)),
);
