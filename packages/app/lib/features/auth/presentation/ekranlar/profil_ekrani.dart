import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';
import '../durum/auth_durumu.dart';

class ProfilEkrani extends ConsumerWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kullanici = ref.watch(authProvider).kullanici;

    final basHarfler = kullanici == null
        ? ''
        : _basHarfleriGetir(kullanici.tamAd);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    tooltip: 'Geri',
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Renkler.lacivert,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 4),

                  const Expanded(
                    child: Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        color: Renkler.lacivert,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      _yakindaMesaji(
                        context,
                        'Bildirim merkezi',
                      );
                    },
                    tooltip: 'Bildirimler',
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Renkler.lacivert,
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (kullanici == null)
                _MisafirProfilKarti(
                  onGirisYap: () {
                    context.push('/giris');
                  },
                  onKayitOl: () {
                    context.push('/kayit');
                  },
                )
              else
                _ProfilUstKarti(
                  basHarfler: basHarfler,
                  tamAd: kullanici.tamAd,
                  email: kullanici.email,
                  rol: kullanici.rol.deger,
                  epostaDogrulandi:
                      kullanici.epostaDogrulandi,
                ),

              const SizedBox(height: 28),

              const Text(
                'Hızlı İşlemler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Renkler.lacivert,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _HizliIslemKarti(
                      ikon: Icons.person_rounded,
                      baslik: 'Profil\nBilgilerim',
                      onTap: () {
                        if (kullanici == null) {
                          context.push('/giris');
                          return;
                        }

                        context.push(
                          '/profil/bilgilerim',
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _HizliIslemKarti(
                      ikon: Icons.lock_outline_rounded,
                      baslik: 'Şifre\nDeğiştir',
                      onTap: () {
                        if (kullanici == null) {
                          context.push('/giris');
                          return;
                        }

                        context.push(
                          '/profil/sifre-degistir',
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _HizliIslemKarti(
                      ikon: Icons.mail_rounded,
                      baslik: 'E-posta\nDeğiştir',
                      onTap: () {
                        if (kullanici == null) {
                          context.push('/giris');
                          return;
                        }

                        context.push(
                          '/profil/eposta-degistir',
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _HizliIslemKarti(
                      ikon: Icons.headset_mic_rounded,
                      baslik: 'Yardım &\nDestek',
                      onTap: () {
                        _yakindaMesaji(
                          context,
                          'Yardım ve destek',
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFFE7EAF0),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ProfilMenuSatiri(
                      ikon: Icons.business_outlined,
                      baslik: 'Firmalarım',
                      aciklama:
                          'Kayıtlı firmalarınızı görüntüleyin',
                      onTap: () {
                        if (kullanici == null) {
                          context.push('/giris');
                          return;
                        }

                        _yakindaMesaji(
                          context,
                          'Firmalarım',
                        );
                      },
                    ),

                    const _MenuAyirici(),

                    _ProfilMenuSatiri(
                      ikon: Icons.work_outline_rounded,
                      baslik: 'İş İlanlarım',
                      aciklama:
                          'Yayınladığınız ilanları görüntüleyin',
                      onTap: () {
                        if (kullanici == null) {
                          context.push('/giris');
                          return;
                        }

                        _yakindaMesaji(
                          context,
                          'İş ilanlarım',
                        );
                      },
                    ),

                    const _MenuAyirici(),

                    _ProfilMenuSatiri(
                      ikon: Icons.campaign_outlined,
                      baslik: 'Duyurularım',
                      aciklama:
                          'Duyuru ve bildirimlerinizi görüntüleyin',
                      onTap: () {
                        if (kullanici == null) {
                          context.push('/giris');
                          return;
                        }

                        _yakindaMesaji(
                          context,
                          'Duyurularım',
                        );
                      },
                    ),

                    const _MenuAyirici(),

                    _ProfilMenuSatiri(
                      ikon: Icons.bookmark_border_rounded,
                      baslik: 'Başvurularım',
                      aciklama:
                          'Yaptığınız başvuruları görüntüleyin',
                      onTap: () {
                        if (kullanici == null) {
                          context.push('/giris');
                          return;
                        }

                        _yakindaMesaji(
                          context,
                          'Başvurularım',
                        );
                      },
                    ),

                    const _MenuAyirici(),

                    _ProfilMenuSatiri(
                      ikon: Icons.favorite_border_rounded,
                      baslik: 'Favorilerim',
                      aciklama:
                          'Kaydettiğiniz ilan ve firmalar',
                      onTap: () {
                        if (kullanici == null) {
                          context.push('/giris');
                          return;
                        }

                        _yakindaMesaji(
                          context,
                          'Favorilerim',
                        );
                      },
                    ),

                    const _MenuAyirici(),

                    _ProfilMenuSatiri(
                      ikon: Icons.settings_outlined,
                      baslik: 'Ayarlar',
                      aciklama:
                          'Uygulama ayarlarınızı yönetin',
                      onTap: () {
                        context.push('/ayarlar');
                      },
                    ),

                    if (kullanici != null) ...[
                      const _MenuAyirici(),

                      _ProfilMenuSatiri(
                        ikon: Icons.logout_rounded,
                        baslik: 'Çıkış Yap',
                        aciklama:
                            'Hesabınızdan güvenli çıkış yapın',
                        kirmizi: true,
                        okGoster: false,
                        onTap: () {
                          _cikisOnayiGoster(
                            context,
                            ref,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _basHarfleriGetir(
    String tamAd,
  ) {
    final kelimeler = tamAd
        .trim()
        .split(' ')
        .where(
          (kelime) => kelime.isNotEmpty,
        )
        .toList();

    if (kelimeler.isEmpty) {
      return '?';
    }

    if (kelimeler.length == 1) {
      return kelimeler.first[0].toUpperCase();
    }

    return '${kelimeler.first[0]}${kelimeler.last[0]}'
        .toUpperCase();
  }

  static void _yakindaMesaji(
    BuildContext context,
    String ozellik,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$ozellik özelliği yakında eklenecek.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static Future<void> _cikisOnayiGoster(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final cikisYapilsin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Çıkış yapılsın mı?',
          ),
          content: const Text(
            'Hesabınızdan çıkış yapmak istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Vazgeç',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
              ),
              child: const Text(
                'Çıkış Yap',
              ),
            ),
          ],
        );
      },
    );

    if (cikisYapilsin == true) {
      await ref
          .read(authProvider.notifier)
          .cikisYap();
    }
  }
}

class _MisafirProfilKarti extends StatelessWidget {
  const _MisafirProfilKarti({
    required this.onGirisYap,
    required this.onKayitOl,
  });

  final VoidCallback onGirisYap;
  final VoidCallback onKayitOl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF082F61),
            Color(0xFF0F5AA6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33082F61),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.45,
                ),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 43,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hesabınıza giriş yapın',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Profil özelliklerinden yararlanmak için giriş yapın veya kayıt olun.',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.82,
                    ),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 13),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: onGirisYap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Renkler.altin,
                        foregroundColor:
                            Renkler.lacivert,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    OutlinedButton(
                      onPressed: onKayitOl,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: Colors.white,
                        ),
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilUstKarti extends StatelessWidget {
  const _ProfilUstKarti({
    required this.basHarfler,
    required this.tamAd,
    required this.email,
    required this.rol,
    required this.epostaDogrulandi,
  });

  final String basHarfler;
  final String tamAd;
  final String email;
  final String rol;
  final bool epostaDogrulandi;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF082F61),
            Color(0xFF0F5AA6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33082F61),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 86,
            height: 86,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.55,
                ),
                width: 2,
              ),
            ),
            child: Text(
              basHarfler,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  tamAd,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.85,
                    ),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _ProfilEtiketi(
                      ikon: Icons.star_rounded,
                      yazi: rol,
                      renk: const Color(
                        0xFFFFC84B,
                      ),
                    ),
                    if (!epostaDogrulandi)
                      const _ProfilEtiketi(
                        ikon:
                            Icons.warning_amber_rounded,
                        yazi:
                            'E-posta doğrulanmadı',
                        renk: Color(
                          0xFFFFC84B,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfilEtiketi extends StatelessWidget {
  const _ProfilEtiketi({
    required this.ikon,
    required this.yazi,
    required this.renk,
  });

  final IconData ikon;
  final String yazi;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            ikon,
            size: 15,
            color: renk,
          ),
          const SizedBox(width: 5),
          Text(
            yazi,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HizliIslemKarti extends StatelessWidget {
  const _HizliIslemKarti({
    required this.ikon,
    required this.baslik,
    required this.onTap,
  });

  final IconData ikon;
  final String baslik;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 128,
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE7EAF0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                ikon,
                size: 31,
                color: const Color(0xFF0D4F96),
              ),

              const SizedBox(height: 13),

              Text(
                baslik,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: Renkler.lacivert,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfilMenuSatiri extends StatelessWidget {
  const _ProfilMenuSatiri({
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    required this.onTap,
    this.kirmizi = false,
    this.okGoster = true,
  });

  final IconData ikon;
  final String baslik;
  final String aciklama;
  final VoidCallback onTap;
  final bool kirmizi;
  final bool okGoster;

  @override
  Widget build(BuildContext context) {
    final anaRenk = kirmizi
        ? const Color(0xFFDC2626)
        : Renkler.lacivert;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kirmizi
                      ? const Color(0xFFFFEEEE)
                      : const Color(0xFFEEF5FC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ikon,
                  color: anaRenk,
                  size: 23,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: anaRenk,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      aciklama,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Renkler.metinIkincil,
                      ),
                    ),
                  ],
                ),
              ),

              if (okGoster)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF667085),
                  size: 27,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuAyirici extends StatelessWidget {
  const _MenuAyirici();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 82,
      endIndent: 18,
      color: Color(0xFFE7EAF0),
    );
  }
}