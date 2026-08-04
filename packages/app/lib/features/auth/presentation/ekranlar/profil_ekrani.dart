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

    // '/profil' açık rota. Giriş yapılmamış kullanıcı burada
    // giriş yapma veya kayıt olma seçenekleriyle karşılanır.
    if (kullanici == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF5FC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      size: 48,
                      color: Renkler.lacivert,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Profil',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Renkler.lacivert,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Profilinizi görüntülemek için giriş yapın.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Renkler.metinIkincil,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/giris');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Renkler.altin,
                      foregroundColor: Renkler.lacivert,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      context.go('/kayit');
                    },
                    child: const Text(
                      'Hesabın yok mu? Kayıt Ol',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final basHarfler = _basHarfleriGetir(
      kullanici.tamAd,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 26,
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
                      size: 27,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Yalnızca görsel amaçlı kullanıcı kartı.
              _ProfilUstKarti(
                basHarfler: basHarfler,
                tamAd: kullanici.tamAd,
                email: kullanici.email,
                rol: kullanici.rol.deger,
                epostaDogrulandi:
                    kullanici.epostaDogrulandi,
              ),

              const SizedBox(height: 24),

              const Text(
                'Hızlı İşlemler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Renkler.lacivert,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _HizliIslemKarti(
                      ikon: Icons.person_outline_rounded,
                      baslik: 'Profil\nBilgilerim',
                      onTap: () {
                        context.push('/profil/bilgilerim');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HizliIslemKarti(
                      ikon: Icons.lock_outline_rounded,
                      baslik: 'Şifre\nDeğiştir',
                      onTap: () {
                        _yakindaMesaji(
                          context,
                          'Şifre değiştirme',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HizliIslemKarti(
                      ikon: Icons.mail_outline_rounded,
                      baslik: 'E-posta\nDeğiştir',
                      onTap: () {
                        _yakindaMesaji(
                          context,
                          'E-posta değiştirme',
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HizliIslemKarti(
                      ikon: Icons.support_agent_rounded,
                      baslik: 'Yardım ve\nDestek',
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

              const SizedBox(height: 22),

              Container(
                decoration: BoxDecoration(
                  color: Renkler.beyaz,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Renkler.kenarlik,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 16,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _ProfilMenuSatiri(
                      ikon: Icons.person_outline_rounded,
                      baslik: 'Profil Bilgilerim',
                      aciklama:
                          'Kişisel bilgilerinizi görüntüleyin',
                      onTap: () {
                        context.push('/profil/bilgilerim');
                      },
                    ),
                    const _MenuAyirici(),
                    _ProfilMenuSatiri(
                      ikon: Icons.business_outlined,
                      baslik: 'Firmam',
                      aciklama:
                          'Bağlı olduğunuz firmayı görüntüleyin',
                      onTap: () {
                        context.go('/firmalar');
                      },
                    ),
                    const _MenuAyirici(),
                    _ProfilMenuSatiri(
                      ikon: Icons.favorite_border_rounded,
                      baslik: 'Favorilerim',
                      aciklama:
                          'Kaydettiğiniz içerikleri görüntüleyin',
                      onTap: () {
                        _yakindaMesaji(
                          context,
                          'Favoriler',
                        );
                      },
                    ),
                    const _MenuAyirici(),
                    _ProfilMenuSatiri(
                      ikon:
                          Icons.notifications_none_rounded,
                      baslik: 'Bildirimler',
                      aciklama:
                          'Bildirim tercihlerinizi yönetin',
                      onTap: () {
                        _yakindaMesaji(
                          context,
                          'Bildirim ayarları',
                        );
                      },
                    ),
                    const _MenuAyirici(),
                    _ProfilMenuSatiri(
                      ikon: Icons.help_outline_rounded,
                      baslik: 'Yardım ve Destek',
                      aciklama:
                          'Sorularınız için destek alın',
                      onTap: () {
                        _yakindaMesaji(
                          context,
                          'Yardım ve destek',
                        );
                      },
                    ),
                    const _MenuAyirici(),
                    _ProfilMenuSatiri(
                      ikon: Icons.settings_outlined,
                      baslik: 'Ayarlar',
                      aciklama:
                          'Uygulama tercihlerinizi yönetin',
                      onTap: () {
                        _yakindaMesaji(
                          context,
                          'Ayarlar',
                        );
                      },
                    ),
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
        .where((kelime) => kelime.isNotEmpty)
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
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
              ),
              child: const Text('Çıkış Yap'),
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
                      ikon: Icons.badge_outlined,
                      yazi: rol,
                      renk: const Color(0xFFFFC84B),
                    ),
                    if (!epostaDogrulandi)
                      const _ProfilEtiketi(
                        ikon:
                            Icons.warning_amber_rounded,
                        yazi: 'E-posta doğrulanmadı',
                        renk: Color(0xFFFFC84B),
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
      color: Renkler.beyaz,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 118,
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Renkler.kenarlik,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                ikon,
                color: const Color(0xFF0F5AA6),
                size: 28,
              ),
              const SizedBox(height: 10),
              Text(
                baslik,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.3,
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
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: kirmizi
                      ? const Color(0xFFFFEEEE)
                      : const Color(0xFFEEF5FC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ikon,
                  color: anaRenk,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: anaRenk,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      aciklama,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Renkler.metinIkincil,
                      ),
                    ),
                  ],
                ),
              ),
              if (okGoster)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Renkler.metinIkincil,
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
      indent: 73,
      endIndent: 16,
      color: Renkler.kenarlik,
    );
  }
}