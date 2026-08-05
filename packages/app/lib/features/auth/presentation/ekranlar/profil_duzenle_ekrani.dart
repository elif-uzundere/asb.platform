// Profil Bilgilerim > Bilgilerimi Düzenle. Ad/soyad/telefon güncelleme —
// e-posta ve şifre BİLEREK burada YOK, onlar kendi ayrı (re-auth gerektiren)
// ekranlarında (eposta_degistir_ekrani.dart, sifre_degistir_ekrani.dart).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../durum/auth_durumu.dart';
import '../durum/profil_duzenle_notifier.dart';

class ProfilDuzenleEkrani extends ConsumerStatefulWidget {
  const ProfilDuzenleEkrani({super.key});

  @override
  ConsumerState<ProfilDuzenleEkrani> createState() => _ProfilDuzenleEkraniDurumu();
}

class _ProfilDuzenleEkraniDurumu extends ConsumerState<ProfilDuzenleEkrani> {
  late final TextEditingController _ad;
  late final TextEditingController _soyad;
  late final TextEditingController _telefon;

  @override
  void initState() {
    super.initState();
    final kullanici = ref.read(authProvider).kullanici;
    _ad = TextEditingController(text: kullanici?.ad ?? '');
    _soyad = TextEditingController(text: kullanici?.soyad ?? '');
    _telefon = TextEditingController(text: kullanici?.telefon ?? '');
  }

  @override
  void dispose() {
    _ad.dispose();
    _soyad.dispose();
    _telefon.dispose();
    super.dispose();
  }

  void _gonder() => ref.read(profilDuzenleNotifierProvider.notifier).gonder(
        ad: _ad.text.trim(),
        soyad: _soyad.text.trim(),
        telefon: _telefon.text.trim().isEmpty ? null : _telefon.text.trim(),
      );

  @override
  Widget build(BuildContext context) {
    ref.listen<IslemDurumu>(profilDuzenleNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Kaydedilemedi',
        basariBasligi: 'Başarılı',
        basariMesaji: 'Profil bilgileriniz güncellendi.',
        basariSonrasi: () => Navigator.of(context).pop(),
        sifirla: ref.read(profilDuzenleNotifierProvider.notifier).sifirla,
      );
    });

    final yukleniyor = ref.watch(profilDuzenleNotifierProvider) is IslemSuruyor;

    return Scaffold(
      backgroundColor: Renkler.beyaz,
      appBar: AppBar(
        title: const Text('Bilgilerimi Düzenle'),
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
                GirdiKutusu(denetleyici: _ad, ipucu: 'Ad', ikon: Icons.person_outline),
                const SizedBox(height: 14),
                GirdiKutusu(
                  denetleyici: _soyad,
                  ipucu: 'Soyad',
                  ikon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
                GirdiKutusu(
                  denetleyici: _telefon,
                  ipucu: 'Telefon (opsiyonel)',
                  ikon: Icons.phone_outlined,
                  klavyeTipi: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                BirincilButon(
                  yazi: yukleniyor ? 'Kaydediliyor...' : 'Kaydet',
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
