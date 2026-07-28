// Kaynak (UX/metin): eski Expo app/sifre-sifirla.tsx (silindi — bkz. docs/izlence-typescript-nestjs(1).md Ek A)
//
// FARK: Eski ekran token boşsa kullanıcıya ham "sıfırlama kodu" alanı
// gösteriyordu. Burada token yalnızca URL/deep link parametresinden okunuyor
// ve kullanıcıya HİÇ gösterilmiyor.
//
// "Token kullanılabilir mi?" kararı ekranda değil, domain'deki
// `sifirlamaTokeniGecerli` kuralında (sifirlamaTokeniGecerliProvider).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../durum/sifre_sifirla_notifier.dart';

class SifreSifirlaEkrani extends ConsumerStatefulWidget {
  const SifreSifirlaEkrani({super.key, required this.token});

  /// E-postadaki linkten gelen tek kullanımlık token (15 dk geçerli).
  final String? token;

  @override
  ConsumerState<SifreSifirlaEkrani> createState() => _SifreSifirlaEkraniDurumu();
}

class _SifreSifirlaEkraniDurumu extends ConsumerState<SifreSifirlaEkrani> {
  final _yeniSifre = TextEditingController();
  bool _sifreGoster = false;

  @override
  void dispose() {
    _yeniSifre.dispose();
    super.dispose();
  }

  void _gonder() => ref.read(sifreSifirlaNotifierProvider.notifier).gonder(
        token: widget.token,
        yeniSifre: _yeniSifre.text,
      );

  @override
  Widget build(BuildContext context) {
    ref.listen<IslemDurumu>(sifreSifirlaNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Hata',
        basariBasligi: 'Başarılı',
        basariMesaji: 'Şifren güncellendi, şimdi giriş yapabilirsin.',
        basariSonrasi: () => context.go('/giris'),
        sifirla: ref.read(sifreSifirlaNotifierProvider.notifier).sifirla,
      );
    });

    final tokenGecerli =
        ref.watch(sifirlamaTokeniGecerliProvider(widget.token));

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
            child: tokenGecerli ? _form() : _tokenYok(),
          ),
        ),
      ),
    );
  }

  Widget _form() {
    final yukleniyor = ref.watch(sifreSifirlaNotifierProvider) is IslemSuruyor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Yeni şifre belirle',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Renkler.lacivert,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'E-posta linkin doğrulandı, yeni şifreni belirle.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Renkler.metinIkincil),
        ),
        const SizedBox(height: 20),
        GirdiKutusu(
          denetleyici: _yeniSifre,
          ipucu: 'Yeni şifre',
          ikon: Icons.lock_outline,
          gizli: !_sifreGoster,
          otomatikDoldurma: const [AutofillHints.newPassword],
          sonEk: SifreGozu(
            gorunur: _sifreGoster,
            degistir: () => setState(() => _sifreGoster = !_sifreGoster),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 4, left: 4),
          child: Text(
            'En az 8 karakter, en az 1 rakam içermeli',
            style: TextStyle(fontSize: 11, color: Renkler.metinIkincil),
          ),
        ),
        const SizedBox(height: 16),
        BirincilButon(
          yazi: yukleniyor ? 'Kaydediliyor...' : 'Şifreyi güncelle',
          yukleniyor: yukleniyor,
          basildi: _gonder,
        ),
      ],
    );
  }

  Widget _tokenYok() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sıfırlama linki geçersiz',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Renkler.lacivert,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Bu sayfaya e-postandaki sıfırlama linkiyle gelmelisin. '
          'Linkin süresi dolmuş olabilir, yeniden isteyebilirsin.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Renkler.metinIkincil),
        ),
        const SizedBox(height: 20),
        BirincilButon(
          yazi: 'Yeni sıfırlama linki iste',
          basildi: () => context.go('/sifremi-unuttum'),
        ),
      ],
    );
  }
}
