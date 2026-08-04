// Kaynak (UX/metin): eski Expo app/giris.tsx (silindi — bkz. docs/izlence-typescript-nestjs(1).md Ek A)
//
// Bu dosya SADECE görünüm: form alanlarını tutar, GirisNotifier'a gönderir,
// durumu dinler. İstek atma / girdi temizleme / hata yakalama burada YOK.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../durum/giris_notifier.dart';

class GirisEkrani extends ConsumerStatefulWidget {
  const GirisEkrani({super.key});

  @override
  ConsumerState<GirisEkrani> createState() => _GirisEkraniDurumu();
}

class _GirisEkraniDurumu extends ConsumerState<GirisEkrani> {
  final _email = TextEditingController();
  final _sifre = TextEditingController();
  bool _sifreGoster = false;
  bool _beniHatirla = false;

  @override
  void dispose() {
    _email.dispose();
    _sifre.dispose();
    super.dispose();
  }

  void _gonder() => ref.read(girisNotifierProvider.notifier).gonder(
        email: _email.text,
        sifre: _sifre.text,
        beniHatirla: _beniHatirla,
      );

  @override
  Widget build(BuildContext context) {
    // Başarıda yönlendirmeyi router'ın redirect'i yapıyor (oturum açıldı → '/').
    ref.listen<IslemDurumu>(girisNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Giriş başarısız',
        sifirla: ref.read(girisNotifierProvider.notifier).sifirla,
      );
    });

    final yukleniyor = ref.watch(girisNotifierProvider) is IslemSuruyor;

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
                  Stack(
                    children: [
                      Image.asset(
                        'assets/images/giris-hero.jpeg',
                        height: 380,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: GeriButonu(
                            basildi: () => context.go('/profil'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: const Offset(0, -28),
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
                            'Hoş geldiniz!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Renkler.lacivert,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Hesabınıza giriş yaparak tüm hizmetlerimize kolayca ulaşabilirsiniz.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Renkler.metinIkincil,
                            ),
                          ),
                          const SizedBox(height: 14),
                          GirdiKutusu(
                            denetleyici: _email,
                            ipucu: 'E-posta veya telefon',
                            ikon: Icons.person_outline,
                            klavyeTipi: TextInputType.emailAddress,
                            otomatikDoldurma: const [AutofillHints.email],
                          ),
                          const SizedBox(height: 14),
                          GirdiKutusu(
                            denetleyici: _sifre,
                            ipucu: 'Şifre',
                            ikon: Icons.lock_outline,
                            gizli: !_sifreGoster,
                            otomatikDoldurma: const [AutofillHints.password],
                            sonEk: SifreGozu(
                              gorunur: _sifreGoster,
                              degistir: () =>
                                  setState(() => _sifreGoster = !_sifreGoster),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => setState(
                                  () => _beniHatirla = !_beniHatirla,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _beniHatirla
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      size: 18,
                                      color: Renkler.lacivert,
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Beni hatırla',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Renkler.metinIkincil,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () => context.push('/sifremi-unuttum'),
                                child: const Text(
                                  'Şifremi unuttum?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Renkler.mavi,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          BirincilButon(
                            yazi:
                                yukleniyor ? 'Giriş yapılıyor...' : 'Giriş yap',
                            yukleniyor: yukleniyor,
                            basildi: _gonder,
                          ),
                          const SizedBox(height: 14),
                          const SosyalGirisSatiri(
                            yakindaMesaji: 'Sosyal giriş henüz eklenmedi.',
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Hesabınız yok mu? ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Renkler.metinIkincil,
                                ),
                              ),
                              InkWell(
                                onTap: () => context.push('/kayit'),
                                child: const Text(
                                  'Kayıt ol',
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
