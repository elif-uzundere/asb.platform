// Profil > E-posta Değiştir. Hassas bir alan olduğu için mevcut şifre
// yeniden istenir (re-auth) — sifre_degistir_ekrani.dart ile AYNI desen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../durum/eposta_degistir_notifier.dart';

class EpostaDegistirEkrani extends ConsumerStatefulWidget {
  const EpostaDegistirEkrani({super.key});

  @override
  ConsumerState<EpostaDegistirEkrani> createState() => _EpostaDegistirEkraniDurumu();
}

class _EpostaDegistirEkraniDurumu extends ConsumerState<EpostaDegistirEkrani> {
  final _yeniEposta = TextEditingController();
  final _mevcutSifre = TextEditingController();
  bool _sifreGoster = false;

  @override
  void dispose() {
    _yeniEposta.dispose();
    _mevcutSifre.dispose();
    super.dispose();
  }

  void _gonder() => ref.read(epostaDegistirNotifierProvider.notifier).gonder(
        yeniEposta: _yeniEposta.text.trim(),
        mevcutSifre: _mevcutSifre.text,
      );

  @override
  Widget build(BuildContext context) {
    ref.listen<IslemDurumu>(epostaDegistirNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'E-posta değiştirilemedi',
        basariBasligi: 'Başarılı',
        basariMesaji: 'E-posta adresiniz güncellendi.',
        basariSonrasi: () => Navigator.of(context).pop(),
        sifirla: ref.read(epostaDegistirNotifierProvider.notifier).sifirla,
      );
    });

    final yukleniyor = ref.watch(epostaDegistirNotifierProvider) is IslemSuruyor;

    return Scaffold(
      backgroundColor: Renkler.beyaz,
      appBar: AppBar(
        title: const Text('E-posta Değiştir'),
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
                  denetleyici: _yeniEposta,
                  ipucu: 'Yeni e-posta',
                  ikon: Icons.mail_outline,
                  klavyeTipi: TextInputType.emailAddress,
                  otomatikDoldurma: const [AutofillHints.email],
                ),
                const SizedBox(height: 14),
                GirdiKutusu(
                  denetleyici: _mevcutSifre,
                  ipucu: 'Mevcut şifre',
                  ikon: Icons.lock_outline,
                  gizli: !_sifreGoster,
                  sonEk: SifreGozu(
                    gorunur: _sifreGoster,
                    degistir: () => setState(() => _sifreGoster = !_sifreGoster),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    'Kimliğinizi doğrulamak için mevcut şifreniz gerekli',
                    style: TextStyle(fontSize: 11, color: Renkler.metinIkincil),
                  ),
                ),
                const SizedBox(height: 20),
                BirincilButon(
                  yazi: yukleniyor ? 'Kaydediliyor...' : 'E-postayı güncelle',
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
