import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/acil_durum/domain/acil_durum_birimi.dart';
import '../../features/acil_durum/presentation/ekranlar/acil_durum_bildir_ekrani.dart';
import '../../features/acil_durum/presentation/ekranlar/acil_durum_ekrani.dart';
import '../../features/acil_durum/presentation/ekranlar/bildirimlerim_ekrani.dart';
import '../../features/acil_durum/presentation/ekranlar/birim_detay_ekrani.dart';
import '../../features/acil_durum/presentation/ekranlar/toplanma_alanlari_ekrani.dart';

import '../models/auth_modelleri.dart';
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
import '../../features/palet_tesisi/presentation/ekranlar/palet_tesisi_yonetim_ekrani.dart';
import '../../features/auth/presentation/ekranlar/sifre_sifirla_ekrani.dart';
import '../../features/auth/presentation/ekranlar/sifremi_unuttum_ekrani.dart';
import '../../features/cookzone/presentation/ekranlar/cookzone_ekrani.dart';
import '../../features/cookzone/presentation/ekranlar/cookzone_isletme_siparisleri_ekrani.dart';
import '../../features/cookzone/presentation/ekranlar/cookzone_sepet_ekrani.dart';
import '../../features/cookzone/presentation/ekranlar/cookzone_siparislerim_ekrani.dart';
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
import '../../features/is_ilanlari/presentation/ekranlar/basvurularim_ekrani.dart';
import '../../features/is_ilanlari/presentation/ekranlar/is_ilani_basvurulari_ekrani.dart';
import '../../features/is_ilanlari/presentation/ekranlar/is_ilani_detay_ekrani.dart';
import '../../features/is_ilanlari/presentation/ekranlar/is_ilanlari_ekrani.dart';
import '../../features/is_ilanlari/presentation/ekranlar/is_ilanlarim_ekrani.dart';
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
      // cookzone_yetkilisi sipariş VEREN ekranı hiç görmemeli — ayrı bir
      // yönetim akışı düşünülmüştü (11.08.2026, Berzan'ın düzeltmesi).
      // Yönlendirme kararı tek yerde (router) toplanıyor, ekranlar kendi
      // içinde tekrar rol kontrolü yapmıyor.
      final kullanici = ref.read(authProvider).kullanici;
      if (state.matchedLocation == '/cookzone' && kullanici?.rol == KullaniciRolu.cookzoneYetkilisi) {
        return '/cookzone/yonetim';
      }
      // palet_tesisi_yetkilisi de aynı gerekçeyle (cookzone_yetkilisi'nin
      // yukarıdaki yönlendirmesiyle aynı, 12.08.2026) müşteri ekranını değil
      // doğrudan yönetim ekranını görmeli.
      if (state.matchedLocation == '/palet-tesisi' && kullanici?.rol == KullaniciRolu.paletTesisiYetkilisi) {
        return '/palet-tesisi/yonetim';
      }
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
        path: '/cookzone',
        builder: (context, state) {
          return const CookzoneEkrani();
        },
      ),

      GoRoute(
        path: '/cookzone/yonetim',
        builder: (context, state) {
          return const CookzoneIsletmeSiparisleriEkrani();
        },
      ),

      GoRoute(
        path: '/palet-tesisi/yonetim',
        builder: (context, state) {
          return const PaletTesisiYonetimEkrani();
        },
      ),

      GoRoute(
        path: '/cookzone/sepet/:id',
        builder: (context, state) {
          return CookzoneSepetEkrani(isletmeId: state.pathParameters['id']!);
        },
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
        path: '/is-ilanlari',
        builder: (context, state) {
          return const IsIlanlariEkrani();
        },
      ),

      GoRoute(
        path: '/is-ilanlari/:id',
        builder: (context, state) {
          return IsIlaniDetayEkrani(ilanId: state.pathParameters['id']!);
        },
      ),

      GoRoute(
        path: '/is-ilanlari/:id/basvurular',
        builder: (context, state) {
          return IsIlaniBasvurulariEkrani(ilanId: state.pathParameters['id']!);
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
        path: '/profil/basvurularim',
        builder: (context, state) {
          return const BasvurularimEkrani();
        },
      ),

      GoRoute(
        path: '/profil/is-ilanlarim',
        builder: (context, state) {
          return const IsIlanlarimEkrani();
        },
      ),

      GoRoute(
        path: '/profil/cookzone-siparislerim',
        builder: (context, state) {
          return const CookzoneSiparislerimEkrani();
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
  path: '/acil-durum/bildir',
  builder: (context, state) {
    return const AcilDurumBildirEkrani();
  },
),
GoRoute(
  path: '/acil-durum/bildirimlerim',
  builder: (context, state) {
    return const BildirimlerimEkrani();
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