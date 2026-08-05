// Profil > Şifre Değiştir. sifre_sifirla_ekrani.dart ile AYNI form deseni —
// FARK: e-postadaki linkten gelen token yerine mevcut şifre istenir (re-auth).

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
  bool _mevcutGoster = false;
  bool _yeniGoster = false;

  @override
  void dispose() {
    _mevcutSifre.dispose();
    _yeniSifre.dispose();
    super.dispose();
  }

  void _gonder() => ref.read(sifreDegistirNotifierProvider.notifier).gonder(
        mevcutSifre: _mevcutSifre.text,
        yeniSifre: _yeniSifre.text,
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
      backgroundColor: Renkler.beyaz,
      appBar: AppBar(
        title: const Text('Şifre Değiştir'),
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
                const SizedBox(height: 14),
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
                  padding: EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    'En az 8 karakter, en az 1 rakam içermeli',
                    style: TextStyle(fontSize: 11, color: Renkler.metinIkincil),
                  ),
                ),
                const SizedBox(height: 20),
                BirincilButon(
                  yazi: yukleniyor ? 'Kaydediliyor...' : 'Şifreyi güncelle',
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
