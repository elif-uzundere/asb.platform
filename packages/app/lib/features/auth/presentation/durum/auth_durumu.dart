// Kaynak: eski Expo src/core/stores/auth.store.ts
// (zustand + persist) karşılığı.
//
// Kayıt sonrası otomatik giriş yapılmıyor.
// Kayıt akışı kayit_notifier.dart içinde yönetiliyor.

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

  /// Güvenli depodan ilk okuma tamamlandı mı?
  ///
  /// Bu işlem tamamlanmadan yönlendirme yapılırsa,
  /// oturumu açık kullanıcı kısa süreliğine giriş ekranına düşebilir.
  final bool hazir;

  bool get girisYapildi {
    return accessToken != null && kullanici != null;
  }
}

class AuthNotifier extends StateNotifier<AuthDurumu> {
  AuthNotifier(
    this._api,
    this._depo,
  ) : super(const AuthDurumu()) {
    _depodanYukle();
  }

  final AuthApi _api;
  final AuthDepo _depo;

  Future<void> _depodanYukle() async {
    final kayit = await _depo.oku();

    if (!mounted) {
      return;
    }

    state = AuthDurumu(
      kullanici: kayit?.kullanici,
      accessToken: kayit?.accessToken,
      hazir: true,
    );
  }

  Future<void> girisYap(
    LoginRequest dto,
  ) async {
    final sonuc = await _api.girisYapIstegi(dto);

    await _depo.yaz(
      AuthKaydi(
        accessToken: sonuc.accessToken,
        kullanici: sonuc.kullanici,
      ),
    );

    if (!mounted) {
      return;
    }

    state = AuthDurumu(
      kullanici: sonuc.kullanici,
      accessToken: sonuc.accessToken,
      hazir: true,
    );
  }

  /// Ad, soyad ve telefon bilgisini şimdilik cihazdaki
  /// oturum deposunda günceller.
  ///
  /// E-posta burada değiştirilmez. E-posta değişikliği ayrı
  /// güvenlik ekranından yapılacaktır.
  ///
  /// Backend profil güncelleme endpointi hazır olduğunda
  /// bu metodun içine gerçek API isteği eklenecektir.
  Future<void> profilBilgileriniGuncelle({
    required String ad,
    required String soyad,
    String? telefon,
  }) async {
    final mevcutKullanici = state.kullanici;
    final mevcutToken = state.accessToken;

    if (mevcutKullanici == null ||
        mevcutToken == null) {
      throw StateError(
        'Profil bilgilerini güncellemek için giriş yapılmalıdır.',
      );
    }

    final temizAd = ad.trim();
    final temizSoyad = soyad.trim();
    final temizTelefon = telefon?.trim();

    final guncellenmisKullanici = KullaniciOzet(
      id: mevcutKullanici.id,
      ad: temizAd,
      soyad: temizSoyad,

      // E-posta bu işlemde değiştirilmez.
      email: mevcutKullanici.email,

      telefon:
          temizTelefon == null || temizTelefon.isEmpty
              ? null
              : temizTelefon,

      rol: mevcutKullanici.rol,
      firmaId: mevcutKullanici.firmaId,
      epostaDogrulandi:
          mevcutKullanici.epostaDogrulandi,
    );

    await _depo.yaz(
      AuthKaydi(
        accessToken: mevcutToken,
        kullanici: guncellenmisKullanici,
      ),
    );

    if (!mounted) {
      return;
    }

    state = AuthDurumu(
      kullanici: guncellenmisKullanici,
      accessToken: mevcutToken,
      hazir: true,
    );
  }

  Future<void> cikisYap() async {
    await _depo.temizle();

    if (!mounted) {
      return;
    }

    state = const AuthDurumu(
      hazir: true,
    );
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthDurumu>(
  (ref) {
    return AuthNotifier(
      ref.watch(authApiProvider),
      ref.watch(authDepoProvider),
    );
  },
);