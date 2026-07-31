// Kaynak (davranış): eski Expo app/_layout.tsx + app/index.tsx (silindi — bkz. docs/izlence-typescript-nestjs(1).md Ek A)
// "giriş yapılmamışsa /giris'e yönlendir" mantığı burada go_router'ın
// redirect callback'i ile kuruldu.
//
// Kaynak: eski Expo app/(admin)/ route grubunun Flutter karşılığı BİLEREK (silindi — bkz. izlence Ek A)
// kurulmadı — admin paneli kararı (rol bazlı route mu, AdminJS mi) henüz
// netleşmedi (bkz. docs/CLAUDE.md → "Henüz Kesinleşmemiş Kararlar").

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ana_sayfa/presentation/ekranlar/ana_sayfa_ekrani.dart';
import '../../features/auth/presentation/durum/auth_durumu.dart';
import '../../features/auth/presentation/ekranlar/giris_ekrani.dart';
import '../../features/auth/presentation/ekranlar/kayit_ekrani.dart';
import '../../features/auth/presentation/ekranlar/profil_ekrani.dart';
import '../../features/auth/presentation/ekranlar/sifre_sifirla_ekrani.dart';
import '../../features/auth/presentation/ekranlar/sifremi_unuttum_ekrani.dart';
import '../../features/duyurular/presentation/ekranlar/duyurular_ekrani.dart';
import '../../features/firmalar/presentation/ekranlar/firma_detay_ekrani.dart';
import '../../features/firmalar/presentation/ekranlar/firmalar_ekrani.dart';
import '../../features/harita/presentation/ekranlar/harita_ekrani.dart';
import 'route_gozlemci.dart';
import 'sekme_kabugu.dart';

/// Oturum gerektirmeyen rotalar.
const Set<String> _acikRotalar = {
  '/giris',
  '/kayit',
  '/sifremi-unuttum',
  '/sifre-sifirla',
};

final yonlendiriciProvider = Provider<GoRouter>((ref) {
  // GoRouter'ı her auth değişiminde yeniden kurmamak için durumu bir
  // Listenable üzerinden besliyoruz.
  final tetikleyici = ValueNotifier<int>(0);
  ref.onDispose(tetikleyici.dispose);
  ref.listen<AuthDurumu>(
    authProvider,
    (onceki, sonraki) {
      if (onceki?.girisYapildi != sonraki.girisYapildi ||
          onceki?.hazir != sonraki.hazir) {
        tetikleyici.value++;
      }
    },
  );

  // initialLocation BİLEREK verilmedi: web'de tarayıcı adresi (ör. e-postadaki
  // /sifre-sifirla?token=... linki) tek yetkili kaynak olsun. Sabit bir '/'
  // verilirse router önce '/' → '/giris' geçişini değerlendirip derin linke
  // sonra iniyor ve giriş ekranı bir an görünüyor.
  return GoRouter(
    refreshListenable: tetikleyici,
    observers: [routeGozlemci],
    redirect: (context, state) {
      final durum = ref.read(authProvider);

      // Depodan okuma bitmeden yönlendirme yapma; yoksa oturumu açık
      // kullanıcı bir an /giris'e düşer.
      if (!durum.hazir) return null;

      final acikRota = _acikRotalar.contains(state.matchedLocation);

      if (!durum.girisYapildi && !acikRota) return '/giris';
      if (durum.girisYapildi && acikRota) return '/';
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, cocuk) => SekmeKabugu(cocuk: cocuk),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const AnaSayfaEkrani(),
          ),
          GoRoute(
            path: '/firmalar',
            builder: (context, state) => const FirmalarEkrani(),
          ),
          GoRoute(
            path: '/harita',
            builder: (context, state) => const HaritaEkrani(),
          ),
          GoRoute(
            path: '/duyurular',
            builder: (context, state) => const DuyurularEkrani(),
          ),
          GoRoute(
            path: '/profil',
            builder: (context, state) => const ProfilEkrani(),
          ),
        ],
      ),
      GoRoute(
        path: '/giris',
        builder: (context, state) => const GirisEkrani(),
      ),
      GoRoute(
        path: '/kayit',
        builder: (context, state) => const KayitEkrani(),
      ),
      GoRoute(
        path: '/sifremi-unuttum',
        builder: (context, state) => const SifremiUnuttumEkrani(),
      ),
      GoRoute(
        path: '/sifre-sifirla',
        // Token e-postadaki linkin query parametresinden gelir:
        // /sifre-sifirla?token=...
        builder: (context, state) =>
            SifreSifirlaEkrani(token: state.uri.queryParameters['token']),
      ),
      // ShellRoute DIŞINDA — detay ekranı tam sayfa açılır, alt sekme
      // çubuğu görünmez ve kendi geri butonuna sahiptir. Derin link
      // (/firmalar/abc123) doğrudan bu rotaya düşer.
      GoRoute(
        path: '/firmalar/:id',
        builder: (context, state) =>
            FirmaDetayEkrani(firmaId: state.pathParameters['id']!),
      ),
    ],
  );
});
