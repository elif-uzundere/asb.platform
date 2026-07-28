// Kaynak (UX/metin): eski Expo app/kayit.tsx (silindi — bkz. docs/izlence-typescript-nestjs(1).md Ek A)
//
// Bu dosya SADECE görünüm. "Kayıt sonrası otomatik giriş yapılmaz" kuralı
// KayitNotifier'da (US-001 sapması, docs/CLAUDE.md'de loglu) — ekran sadece
// başarıda /giris'e yönlendiriyor.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../durum/kayit_notifier.dart';

class KayitEkrani extends ConsumerStatefulWidget {
  const KayitEkrani({super.key});

  @override
  ConsumerState<KayitEkrani> createState() => _KayitEkraniDurumu();
}

class _KayitEkraniDurumu extends ConsumerState<KayitEkrani> {
  final _ad = TextEditingController();
  final _soyad = TextEditingController();
  final _email = TextEditingController();
  final _sifre = TextEditingController();
  final _telefon = TextEditingController();
  bool _sifreGoster = false;

  @override
  void dispose() {
    _ad.dispose();
    _soyad.dispose();
    _email.dispose();
    _sifre.dispose();
    _telefon.dispose();
    super.dispose();
  }

  void _gonder() => ref.read(kayitNotifierProvider.notifier).gonder(
        ad: _ad.text,
        soyad: _soyad.text,
        email: _email.text,
        sifre: _sifre.text,
        telefon: _telefon.text,
      );

  @override
  Widget build(BuildContext context) {
    ref.listen<IslemDurumu>(kayitNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Kayıt başarısız',
        basariBasligi: 'Kayıt başarılı',
        basariMesaji: 'Şimdi giriş yapabilirsiniz.',
        basariSonrasi: () => context.go('/giris'),
        sifirla: ref.read(kayitNotifierProvider.notifier).sifirla,
      );
    });

    final yukleniyor = ref.watch(kayitNotifierProvider) is IslemSuruyor;

    return Scaffold(
      backgroundColor: Renkler.beyaz,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/giris-hero.jpeg',
                    height: 320,
                    fit: BoxFit.cover,
                  ),
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Renkler.beyaz,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Hesap oluştur',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Renkler.lacivert,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Birkaç bilgiyle bölgenin tüm hizmetlerine erişin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Renkler.metinIkincil,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GirdiKutusu(
                                  denetleyici: _ad,
                                  ipucu: 'Ad',
                                  ikon: Icons.person_outline,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GirdiKutusu(
                                  denetleyici: _soyad,
                                  ipucu: 'Soyad',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GirdiKutusu(
                            denetleyici: _email,
                            ipucu: 'E-posta',
                            ikon: Icons.mail_outline,
                            klavyeTipi: TextInputType.emailAddress,
                            otomatikDoldurma: const [AutofillHints.email],
                          ),
                          const SizedBox(height: 12),
                          GirdiKutusu(
                            denetleyici: _telefon,
                            ipucu: 'Telefon (opsiyonel)',
                            ikon: Icons.phone_outlined,
                            klavyeTipi: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          GirdiKutusu(
                            denetleyici: _sifre,
                            ipucu: 'Şifre',
                            ikon: Icons.lock_outline,
                            gizli: !_sifreGoster,
                            otomatikDoldurma: const [AutofillHints.newPassword],
                            sonEk: SifreGozu(
                              gorunur: _sifreGoster,
                              degistir: () =>
                                  setState(() => _sifreGoster = !_sifreGoster),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'En az 8 karakter, en az 1 rakam içermeli',
                              style: TextStyle(
                                fontSize: 11,
                                color: Renkler.metinIkincil,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          BirincilButon(
                            yazi: yukleniyor ? 'Kaydediliyor...' : 'Kayıt ol',
                            yukleniyor: yukleniyor,
                            basildi: _gonder,
                          ),
                          const SizedBox(height: 14),
                          const SosyalGirisSatiri(
                            yakindaMesaji: 'Sosyal kayıt henüz eklenmedi.',
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Zaten hesabınız var mı? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Renkler.metinIkincil,
                                ),
                              ),
                              InkWell(
                                onTap: () => context.go('/giris'),
                                child: const Text(
                                  'Giriş yap',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Renkler.mavi,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
