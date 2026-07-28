// Oturum bilgisinin (accessToken + kullanıcı) kalıcı saklanması.
// Kaynak: eski Expo src/core/stores/auth.store.ts'deki zustand `persist` (silindi — bkz. izlence Ek A)
// katmanının karşılığı — aynı JSON şekli, aynı depo anahtarı ('asb-auth').

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_modelleri.dart';
import 'guvenli_depo.dart';

class AuthKaydi {
  const AuthKaydi({required this.accessToken, required this.kullanici});

  final String accessToken;
  final KullaniciOzet kullanici;

  Map<String, dynamic> jsonaDonustur() => {
        'accessToken': accessToken,
        'kullanici': kullanici.jsonaDonustur(),
      };

  factory AuthKaydi.jsondan(Map<String, dynamic> json) => AuthKaydi(
        accessToken: json['accessToken'] as String,
        kullanici:
            KullaniciOzet.jsondan(json['kullanici'] as Map<String, dynamic>),
      );
}

class AuthDepo {
  const AuthDepo(this._depo);

  final GuvenliDepo _depo;

  Future<AuthKaydi?> oku() async {
    final ham = await _depo.oku(GuvenliDepo.authAnahtari);
    if (ham == null || ham.isEmpty) return null;
    try {
      return AuthKaydi.jsondan(jsonDecode(ham) as Map<String, dynamic>);
    } catch (_) {
      // Bozuk/eski formatta kayıt: sessizce temizle, oturumsuz başla.
      await temizle();
      return null;
    }
  }

  /// Interceptor'ın ihtiyaç duyduğu tek alan — tüm kaydı çözmeye gerek yok.
  Future<String?> tokenOku() async => (await oku())?.accessToken;

  Future<void> yaz(AuthKaydi kayit) =>
      _depo.yaz(GuvenliDepo.authAnahtari, jsonEncode(kayit.jsonaDonustur()));

  Future<void> temizle() => _depo.sil(GuvenliDepo.authAnahtari);
}

final authDepoProvider =
    Provider<AuthDepo>((ref) => AuthDepo(ref.watch(guvenliDepoProvider)));
