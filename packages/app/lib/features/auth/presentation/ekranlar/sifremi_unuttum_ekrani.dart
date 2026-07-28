// Kaynak (UX/metin): eski Expo app/sifremi-unuttum.tsx (silindi — bkz. docs/izlence-typescript-nestjs(1).md Ek A)
// Bu dosya SADECE görünüm — istek SifremiUnuttumNotifier'da.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../durum/sifremi_unuttum_notifier.dart';

class SifremiUnuttumEkrani extends ConsumerStatefulWidget {
  const SifremiUnuttumEkrani({super.key});

  @override
  ConsumerState<SifremiUnuttumEkrani> createState() =>
      _SifremiUnuttumEkraniDurumu();
}

class _SifremiUnuttumEkraniDurumu extends ConsumerState<SifremiUnuttumEkrani> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _gonder() => ref
      .read(sifremiUnuttumNotifierProvider.notifier)
      .gonder(email: _email.text);

  @override
  Widget build(BuildContext context) {
    ref.listen<IslemDurumu>(sifremiUnuttumNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Hata',
        basariBasligi: 'E-posta gönderildi',
        basariMesaji:
            'Sistemde bu e-posta kayıtlıysa, sıfırlama linki gönderildi.',
        basariSonrasi: () => context.go('/giris'),
        sifirla: ref.read(sifremiUnuttumNotifierProvider.notifier).sifirla,
      );
    });

    final yukleniyor =
        ref.watch(sifremiUnuttumNotifierProvider) is IslemSuruyor;

    return Scaffold(
      backgroundColor: Renkler.beyaz,
      appBar: AppBar(
        backgroundColor: Renkler.beyaz,
        foregroundColor: Renkler.lacivert,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Şifreni mi unuttun?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Renkler.lacivert,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'E-postanı gir, sıfırlama linki gönderelim.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Renkler.metinIkincil),
                ),
                const SizedBox(height: 20),
                GirdiKutusu(
                  denetleyici: _email,
                  ipucu: 'E-posta',
                  ikon: Icons.mail_outline,
                  klavyeTipi: TextInputType.emailAddress,
                  otomatikDoldurma: const [AutofillHints.email],
                ),
                const SizedBox(height: 12),
                BirincilButon(
                  yazi: yukleniyor
                      ? 'Gönderiliyor...'
                      : 'Sıfırlama linki gönder',
                  yukleniyor: yukleniyor,
                  basildi: _gonder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
