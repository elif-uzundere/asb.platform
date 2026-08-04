// Kaynak: eski Expo app/(tabs)/index.tsx (silindi — bkz. izlence Ek A)
//
// Mockup'taki "Hızlı Erişim" ızgarası burada eklendi. Her ikonun aktif olup
// olmadığı (yani gerçek bir modüle mi gittiği, yoksa "Yakında" mı gösterdiği)
// domain/hizli_erisim_kurallari.dart'ta — bu dosya sadece görünüm.
//
// Ana Sayfa artık ASB'nin kendi web sitesi gibi oturum açmadan da görülebilen
// bir karşılama sayfası (bkz. yonlendirici.dart _acikRotalar'daki '/' notu).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';
import '../../../is_ortaklari/presentation/widgetlar/is_ortaklari_bolumu.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/duyurular_hizli_erisim_karti.dart';
import '../widgets/hizli_erisim_izgarasi.dart';

/// Ana Sayfa artık kendi header'ı olmayan, ASB'nin kendi web sitesindeki
/// gibi doğrudan hero banner ile açılan bir karşılama sayfası (bkz.
/// kullanıcının paylaştığı ekran görüntüsü). Giriş Yap/Kayıt Ol/Çıkış
/// artık Profil sekmesinden erişiliyor; iletişim bilgileri (eskiden
/// buradaki footer'da idi) de Profil > İletişim'e taşınacak.
class AnaSayfaEkrani extends StatelessWidget {
  const AnaSayfaEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerCarousel(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BolumBasligi('Hızlı Erişim'),
                    const HizliErisimIzgarasi(),
                    const SizedBox(height: 8),
                    const _BolumBasligi('Öne Çıkanlar ve İş Ortakları'),
                    DuyurularHizliErisimKarti(onTap: () => context.go('/duyurular')),
                    const SizedBox(height: 12),
                    const IsOrtaklariBolumu(),
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

class _BolumBasligi extends StatelessWidget {
  const _BolumBasligi(this.yazi);

  final String yazi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: Text(
        yazi,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Renkler.lacivert,
        ),
      ),
    );
  }
}
