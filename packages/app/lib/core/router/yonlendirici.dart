// Kaynak (davranış): eski Expo app/_layout.tsx + app/index.tsx
// (silindi — bkz. docs/izlence-typescript-nestjs(1).md Ek A)
//
// "Giriş yapılmamışsa /giris'e yönlendir" mantığı burada
// go_router'ın redirect callback'i ile kuruldu.
//
// Kaynak: eski Expo app/(admin)/ route grubunun Flutter karşılığı
// BİLEREK kurulmadı. Admin paneli artık Flutter içinde değil,
// AdminJS üzerinden yönetiliyor.

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
import '../../features/duyurular/presentation/ekranlar/duyuru_detay_ekrani.dart';
import '../../features/duyurular/presentation/ekranlar/duyurular_ekrani.dart';
import '../../features/firmalar/presentation/ekranlar/firma_detay_ekrani.dart';
import '../../features/firmalar/presentation/ekranlar/firmalar_ekrani.dart';
import '../../features/harita/presentation/ekranlar/harita_ekrani.dart';
import '../../features/is_ortaklari/presentation/ekranlar/is_ortaklari_ekrani.dart';
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
  // GoRouter'ı her auth değişiminde yeniden kurmamak için durumu
  // bir Listenable üzerinden besliyoruz.
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

  // initialLocation bilerek verilmedi.
  // Web'de tarayıcı adresi tek yetkili kaynak olsun.
  return GoRouter(
    refreshListenable: tetikleyici,
    observers: [routeGozlemci],

    redirect: (context, state) {
      final durum = ref.read(authProvider);

      // Depodan okuma bitmeden yönlendirme yapma.
      if (!durum.hazir) {
        return null;
      }

      final acikRota = _acikRotalar.contains(
        state.matchedLocation,
      );

      // Giriş yapılmamışsa açık olmayan sayfalara gidilemez.
      if (!durum.girisYapildi && !acikRota) {
        return '/giris';
      }

      // Giriş yapılmışsa giriş/kayıt ekranlarına geri gönderme.
      if (durum.girisYapildi && acikRota) {
        return '/';
      }

      return null;
    },

    routes: [
      // Alt sekme çubuğunun görüneceği ana sayfalar.
      ShellRoute(
        builder: (context, state, cocuk) {
          return SekmeKabugu(cocuk: cocuk);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return const AnaSayfaEkrani();
            },
          ),

          GoRoute(
            path: '/firmalar',
            builder: (context, state) {
              return const FirmalarEkrani();
            },
          ),

          GoRoute(
            path: '/harita',
            builder: (context, state) {
              return const HaritaEkrani();
            },
          ),

          GoRoute(
            path: '/duyurular',
            builder: (context, state) {
              return const DuyurularEkrani();
            },
          ),

          // Yeni eklediğimiz iş ortakları sayfası.
          GoRoute(
            path: '/is-ortaklari',
            builder: (context, state) {
              return const IsOrtaklariEkrani();
            },
          ),

          GoRoute(
            path: '/profil',
            builder: (context, state) {
              return const ProfilEkrani();
            },
          ),
        ],
      ),

      // Giriş ve kayıt sayfaları ShellRoute dışında.
      GoRoute(
        path: '/giris',
        builder: (context, state) {
          return const GirisEkrani();
        },
      ),

      GoRoute(
        path: '/kayit',
        builder: (context, state) {
          return const KayitEkrani();
        },
      ),

      GoRoute(
        path: '/sifremi-unuttum',
        builder: (context, state) {
          return const SifremiUnuttumEkrani();
        },
      ),

      GoRoute(
        path: '/sifre-sifirla',
        builder: (context, state) {
          return SifreSifirlaEkrani(
            token: state.uri.queryParameters['token'],
          );
        },
      ),

      // Firma detay ekranı tam sayfa açılır.
      // Alt sekme çubuğu görünmez.
      GoRoute(
        path: '/firmalar/:id',
        builder: (context, state) {
          return FirmaDetayEkrani(
            firmaId: state.pathParameters['id']!,
          );
        },
      ),

      // Duyuru detay ekranı tam sayfa açılır.
      GoRoute(
        path: '/duyurular/:id',
        builder: (context, state) {
          return DuyuruDetayEkrani(
            duyuruId: state.pathParameters['id']!,
          );
        },
      ),
    ],
  );
});