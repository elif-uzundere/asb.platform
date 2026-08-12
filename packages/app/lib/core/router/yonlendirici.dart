import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/acil_durum/domain/acil_durum_birimi.dart';
import '../../features/acil_durum/presentation/ekranlar/acil_durum_ekrani.dart';
import '../../features/acil_durum/presentation/ekranlar/birim_detay_ekrani.dart';
import '../../features/acil_durum/presentation/ekranlar/toplanma_alanlari_ekrani.dart';
import '../../features/ana_sayfa/presentation/ekranlar/ana_sayfa_ekrani.dart';
import '../../features/auth/presentation/durum/auth_durumu.dart';
import '../../features/auth/presentation/ekranlar/ayarlar_ekrani.dart';
import '../../features/auth/presentation/ekranlar/eposta_degistir_ekrani.dart';
import '../../features/auth/presentation/ekranlar/giris_ekrani.dart';
import '../../features/auth/presentation/ekranlar/kayit_ekrani.dart';
import '../../features/auth/presentation/ekranlar/profil_bilgilerim_ekrani.dart';
import '../../features/auth/presentation/ekranlar/profil_duzenle_ekrani.dart';
import '../../features/auth/presentation/ekranlar/profil_ekrani.dart';
import '../../features/auth/presentation/ekranlar/sifre_degistir_ekrani.dart';
import '../../features/palet_tesisi/presentation/ekranlar/palet_tesisi_ekrani.dart';
import '../../features/auth/presentation/ekranlar/sifre_sifirla_ekrani.dart';
import '../../features/auth/presentation/ekranlar/sifremi_unuttum_ekrani.dart';
import '../../features/destek/presentation/ekranlar/destek_icerik_ekrani.dart';
import '../../features/destek/presentation/ekranlar/taleplerim_ekrani.dart';
import '../../features/destek/presentation/ekranlar/yardim_destek_ekrani.dart';
import '../../features/duyurular/presentation/ekranlar/duyuru_detay_ekrani.dart';
import '../../features/duyurular/presentation/ekranlar/duyurular_ekrani.dart';
import '../../features/firmalar/presentation/ekranlar/firma_detay_ekrani.dart';
import '../../features/firmalar/presentation/ekranlar/firmalar_ekrani.dart';
import '../../features/harita/presentation/ekranlar/harita_ekrani.dart';
import '../../features/ikinci_el/presentation/ekranlar/ikinci_el_ilan_ekle_ekrani.dart';
import '../../features/ikinci_el/presentation/ekranlar/ikinci_el_ilanlari_ekrani.dart';
import '../../features/is_ortaklari/presentation/ekranlar/is_ortaklari_ekrani.dart';
import 'route_gozlemci.dart';
import 'sekme_kabugu.dart';

final yonlendiriciProvider = Provider<GoRouter>((ref) {
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

  return GoRouter(
    initialLocation: '/',
    refreshListenable: tetikleyici,
    observers: [routeGozlemci],

    redirect: (context, state) {
      return null;
    },

    routes: [
      ShellRoute(
        builder: (context, state, cocuk) {
          return SekmeKabugu(
            cocuk: cocuk,
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              return const AnaSayfaEkrani();
            },
          ),
          GoRoute(
  path: '/palet-tesisi',
  builder: (context, state) {
    return const PaletTesisiEkrani();
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
          GoRoute(
            path: '/profil',
            builder: (context, state) {
              return const ProfilEkrani();
            },
          ),
        ],
      ),

      GoRoute(
        path: '/ikinci-el',
        builder: (context, state) {
          return const IkinciElIlanlariEkrani();
        },
      ),

      GoRoute(
        path: '/ikinci-el/ilan-ekle',
        builder: (context, state) {
          return const IkinciElIlanEkleEkrani();
        },
      ),

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

      GoRoute(
        path: '/firmalar/:id',
        builder: (context, state) {
          return FirmaDetayEkrani(
            firmaId: state.pathParameters['id']!,
          );
        },
      ),

      GoRoute(
        path: '/duyurular/:id',
        builder: (context, state) {
          return DuyuruDetayEkrani(
            duyuruId: state.pathParameters['id']!,
          );
        },
      ),

      GoRoute(
        path: '/is-ortaklari',
        builder: (context, state) {
          return const IsOrtaklariEkrani();
        },
      ),

      GoRoute(
        path: '/profil/bilgilerim',
        builder: (context, state) {
          return const ProfilBilgilerimEkrani();
        },
      ),

      GoRoute(
        path: '/profil/bilgilerim/duzenle',
        builder: (context, state) {
          return const ProfilDuzenleEkrani();
        },
      ),

      GoRoute(
        path: '/profil/sifre-degistir',
        builder: (context, state) {
          return const SifreDegistirEkrani();
        },
      ),

      GoRoute(
        path: '/profil/eposta-degistir',
        builder: (context, state) {
          return const EpostaDegistirEkrani();
        },
      ),

      GoRoute(
        path: '/profil/yardim-destek',
        builder: (context, state) {
          return const YardimDestekEkrani();
        },
      ),
GoRoute(
  path: '/acil-durum',
  builder: (context, state) {
    return const AcilDurumEkrani();
  },
),
GoRoute(
  path: '/acil-durum/birim',
  builder: (context, state) {
    final birim = state.extra as AcilDurumBirimi;

    return BirimDetayEkrani(
      birim: birim,
    );
  },
),
GoRoute(
  path: '/acil-durum/toplanma-alanlari',
  builder: (context, state) {
    return const ToplanmaAlanlariEkrani();
  },
),
      GoRoute(
        path: '/profil/yardim-destek/taleplerim',
        builder: (context, state) {
          return const TaleplerimEkrani();
        },
      ),

      GoRoute(
        path: '/profil/yardim-destek/icerik/:anahtar',
        builder: (context, state) {
          return DestekIcerikEkrani(
            anahtar: state.pathParameters['anahtar']!,
          );
        },
      ),

      GoRoute(
        path: '/ayarlar',
        builder: (context, state) {
          return const AyarlarEkrani();
        },
      ),
    ],
  );
});