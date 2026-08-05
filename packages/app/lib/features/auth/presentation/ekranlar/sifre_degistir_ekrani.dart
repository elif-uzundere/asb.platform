// Profil > Şifre Değiştir. E-postadaki sıfırlama linkinden FARKLI: burada
// oturum zaten açık, kimlik "mevcut şifre" ile yeniden doğrulanıyor (re-auth).
//
// Görsel dil: duyurular_ekrani.dart/firmalar_ekrani.dart'taki lacivert→mavi
// degrade "hero" başlık + altında tam sayfayı dolduran beyaz kart —
// uygulamanın geri kalanıyla AYNI desen, eskisi gibi ekranın ortasında
// küçük bir form değil.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../durum/sifre_degistir_notifier.dart';

class SifreDegistirEkrani extends ConsumerStatefulWidget {
  const SifreDegistirEkrani({super.key});

  @override
  ConsumerState<SifreDegistirEkrani> createState() => _SifreDegistirEkraniDurumu();
}

class _SifreDegistirEkraniDurumu extends ConsumerState<SifreDegistirEkrani> {
  final _mevcutSifre = TextEditingController();
  final _yeniSifre = TextEditingController();
  final _yeniSifreTekrar = TextEditingController();
  bool _mevcutGoster = false;
  bool _yeniGoster = false;
  bool _tekrarGoster = false;

  @override
  void dispose() {
    _mevcutSifre.dispose();
    _yeniSifre.dispose();
    _yeniSifreTekrar.dispose();
    super.dispose();
  }

  void _gonder() => ref.read(sifreDegistirNotifierProvider.notifier).gonder(
        mevcutSifre: _mevcutSifre.text,
        yeniSifre: _yeniSifre.text,
        yeniSifreTekrar: _yeniSifreTekrar.text,
      );

  @override
  Widget build(BuildContext context) {
    ref.listen<IslemDurumu>(sifreDegistirNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Şifre değiştirilemedi',
        basariBasligi: 'Başarılı',
        basariMesaji: 'Şifreniz güncellendi.',
        basariSonrasi: () => Navigator.of(context).pop(),
        sifirla: ref.read(sifreDegistirNotifierProvider.notifier).sifirla,
      );
    });

    final yukleniyor = ref.watch(sifreDegistirNotifierProvider) is IslemSuruyor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _UstBaslik(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Mevcut Şifreniz',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Renkler.lacivert,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GirdiKutusu(
                      denetleyici: _mevcutSifre,
                      ipucu: 'Mevcut şifre',
                      ikon: Icons.lock_outline,
                      gizli: !_mevcutGoster,
                      sonEk: SifreGozu(
                        gorunur: _mevcutGoster,
                        degistir: () => setState(() => _mevcutGoster = !_mevcutGoster),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Yeni Şifre',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Renkler.lacivert,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GirdiKutusu(
                      denetleyici: _yeniSifre,
                      ipucu: 'Yeni şifre',
                      ikon: Icons.lock_reset_outlined,
                      gizli: !_yeniGoster,
                      otomatikDoldurma: const [AutofillHints.newPassword],
                      sonEk: SifreGozu(
                        gorunur: _yeniGoster,
                        degistir: () => setState(() => _yeniGoster = !_yeniGoster),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'En az 8 karakter, en az 1 rakam içermeli',
                        style: TextStyle(fontSize: 11, color: Renkler.metinIkincil),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GirdiKutusu(
                      denetleyici: _yeniSifreTekrar,
                      ipucu: 'Yeni şifre (tekrar)',
                      ikon: Icons.lock_reset_outlined,
                      gizli: !_tekrarGoster,
                      otomatikDoldurma: const [AutofillHints.newPassword],
                      sonEk: SifreGozu(
                        gorunur: _tekrarGoster,
                        degistir: () => setState(() => _tekrarGoster = !_tekrarGoster),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'İki şifre birbirinin aynısı olmalı, aksi hâlde şifreniz değişmez',
                        style: TextStyle(fontSize: 11, color: Renkler.metinIkincil),
                      ),
                    ),
                    const SizedBox(height: 28),
                    BirincilButon(
                      yazi: yukleniyor ? 'Kaydediliyor...' : 'Şifreyi güncelle',
                      yukleniyor: yukleniyor,
                      basildi: _gonder,
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
}

class _UstBaslik extends StatelessWidget {
  const _UstBaslik();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Renkler.lacivert, Renkler.mavi],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Renkler.beyaz),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 8),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Renkler.beyaz.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset_rounded, color: Renkler.beyaz, size: 26),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 14),
              child: Text(
                'Şifre Değiştir',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Renkler.beyaz,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 6, right: 12),
              child: Text(
                'Hesabınızın güvenliği için mevcut şifrenizi doğrulayıp '
                'yeni bir şifre belirleyin.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1), height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
