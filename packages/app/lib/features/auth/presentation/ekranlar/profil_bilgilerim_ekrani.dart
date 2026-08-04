import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';
import '../durum/auth_durumu.dart';

class ProfilBilgilerimEkrani extends ConsumerWidget {
  const ProfilBilgilerimEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kullanici = ref.watch(authProvider).kullanici;

    if (kullanici == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          title: const Text('Profil Bilgilerim'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              context.go('/giris');
            },
            child: const Text('Giriş Yap'),
          ),
        ),
      );
    }

    final basHarfler = _basHarfleriGetir(
      kullanici.tamAd,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profil');
            }
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Renkler.lacivert,
          ),
          tooltip: 'Geri',
        ),
        title: const Text(
          'Profil Bilgilerim',
          style: TextStyle(
            color: Renkler.lacivert,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          28,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KullaniciOzetiKarti(
              basHarfler: basHarfler,
              tamAd: kullanici.tamAd,
              email: kullanici.email,
              rol: kullanici.rol.deger,
            ),

            const SizedBox(height: 24),

            const Text(
              'Kişisel Bilgiler',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Renkler.lacivert,
              ),
            ),

            const SizedBox(height: 12),

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
                  _BilgiSatiri(
                    ikon: Icons.person_outline_rounded,
                    etiket: 'Ad Soyad',
                    deger: kullanici.tamAd,
                  ),
                  const _Ayirici(),

                  _BilgiSatiri(
                    ikon: Icons.mail_outline_rounded,
                    etiket: 'E-posta',
                    deger: kullanici.email,
                    altBilgi: kullanici.epostaDogrulandi
                        ? 'Doğrulandı'
                        : 'Henüz doğrulanmadı',
                    altBilgiRengi:
                        kullanici.epostaDogrulandi
                            ? const Color(0xFF15803D)
                            : Renkler.altin,
                  ),
                  const _Ayirici(),

                  const _BilgiSatiri(
                    ikon: Icons.phone_outlined,
                    etiket: 'Telefon',
                    deger: 'Henüz eklenmedi',
                  ),
                  const _Ayirici(),

                  _BilgiSatiri(
                    ikon: Icons.badge_outlined,
                    etiket: 'Rol',
                    deger: kullanici.rol.deger,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Profil düzenleme özelliği yakında eklenecek.',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                label: const Text(
                  'Bilgilerimi Düzenle',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Renkler.lacivert,
                  foregroundColor: Renkler.beyaz,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
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
}

class _KullaniciOzetiKarti extends StatelessWidget {
  const _KullaniciOzetiKarti({
    required this.basHarfler,
    required this.tamAd,
    required this.email,
    required this.rol,
  });

  final String basHarfler;
  final String tamAd;
  final String email;
  final String rol;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(20),
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
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF082F61),
                  Color(0xFF0F5AA6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Text(
              basHarfler,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 16),

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
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Renkler.lacivert,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Renkler.metinIkincil,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF4D6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rol,
                    style: const TextStyle(
                      color: Color(0xFF9A6700),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BilgiSatiri extends StatelessWidget {
  const _BilgiSatiri({
    required this.ikon,
    required this.etiket,
    required this.deger,
    this.altBilgi,
    this.altBilgiRengi,
  });

  final IconData ikon;
  final String etiket;
  final String deger;
  final String? altBilgi;
  final Color? altBilgiRengi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF5FC),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ikon,
              color: Renkler.lacivert,
              size: 21,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  etiket,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Renkler.metinIkincil,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deger,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Renkler.lacivert,
                  ),
                ),
                if (altBilgi != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    altBilgi!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: altBilgiRengi ??
                          Renkler.metinIkincil,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ayirici extends StatelessWidget {
  const _Ayirici();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Renkler.kenarlik,
    );
  }
}