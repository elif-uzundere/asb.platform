// Profil > E-posta Değiştir. Hassas bir alan olduğu için mevcut şifre
// yeniden istenir (re-auth) — sifre_degistir_ekrani.dart ile AYNI görsel
// desen (gradient hero + tam sayfa kart).
//
// TODO(gelecek iş — gerçek e-posta doğrulaması): Şu an değişiklik ANINDA
// uygulanıyor, yeni adrese gönderilen bir doğrulama kodu YOK (gerçek
// e-posta gönderimiyle şu aşamada işimiz yok — Mailtrap sadece şifre
// sıfırlama akışında kullanılıyor). İleride: backend'de tek kullanımlık
// bir doğrulama kodu üretilip yeni adrese gönderilmeli, bu ekranda da
// "kodu gir" adımı eklenmeli (sifre_sifirla_ekrani.dart'taki token akışına
// benzer). Unutma diye buraya ve proje hafızasına not düşüldü.

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
                      'Yeni E-posta',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Renkler.lacivert,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GirdiKutusu(
                      denetleyici: _yeniEposta,
                      ipucu: 'ornek@eposta.com',
                      ikon: Icons.mail_outline,
                      klavyeTipi: TextInputType.emailAddress,
                      otomatikDoldurma: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Kimlik Doğrulama',
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
                      gizli: !_sifreGoster,
                      sonEk: SifreGozu(
                        gorunur: _sifreGoster,
                        degistir: () => setState(() => _sifreGoster = !_sifreGoster),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 6, left: 4),
                      child: Text(
                        'Kimliğinizi doğrulamak için mevcut şifreniz gerekli',
                        style: TextStyle(fontSize: 11, color: Renkler.metinIkincil),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _BilgiSeridi(),
                    const SizedBox(height: 28),
                    BirincilButon(
                      yazi: yukleniyor ? 'Kaydediliyor...' : 'E-postayı güncelle',
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

/// Kullanıcıya dürüst bir uyarı: şu an değişiklik anında uygulanıyor,
/// yeni adrese kod gönderilmiyor (bkz. dosya başındaki TODO notu).
class _BilgiSeridi extends StatelessWidget {
  const _BilgiSeridi();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Renkler.mavi.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Renkler.mavi.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Renkler.mavi, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'E-postanız şimdilik onay kodu olmadan hemen değişir. '
              'Doğrulama kodu gönderimi yakında eklenecek.',
              style: TextStyle(fontSize: 11.5, color: Renkler.lacivert, height: 1.4),
            ),
          ),
        ],
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
                child: const Icon(Icons.mark_email_read_outlined, color: Renkler.beyaz, size: 26),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12, top: 14),
              child: Text(
                'E-posta Değiştir',
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
                'Hesabınıza bağlı e-posta adresini güncelleyin.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1), height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
