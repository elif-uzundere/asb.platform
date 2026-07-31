// Kaynak: eski Expo app/(tabs)/index.tsx (silindi — bkz. izlence Ek A)
//
// Mockup'taki "Hızlı Erişim" ızgarası burada eklendi. Her ikonun aktif olup
// olmadığı (yani gerçek bir modüle mi gittiği, yoksa "Yakında" mı gösterdiği)
// domain/hizli_erisim_kurallari.dart'ta — bu dosya sadece görünüm.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/duyurular_hizli_erisim_karti.dart';
import '../widgets/hizli_erisim_izgarasi.dart';

class AnaSayfaEkrani extends StatelessWidget {
  const AnaSayfaEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerCarousel(),
              const _BolumBasligi('Hızlı Erişim'),
              const HizliErisimIzgarasi(),
              const SizedBox(height: 8),
              const _BolumBasligi('Öne Çıkanlar ve İş Ortakları'),
              DuyurularHizliErisimKarti(onTap: () => context.go('/duyurular')),
              const SizedBox(height: 12),
              const _YakindaKarti(),
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

/// İş ortakları modülü henüz yazılmadı — duyurular artık gerçek (yukarıdaki
/// karttan erişilebiliyor), sahte bir kart uydurmak yerine ne olacağını
/// açıkça söyleyen tek bir bilgi kartı gösteriliyor.
class _YakindaKarti extends StatelessWidget {
  const _YakindaKarti();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Renkler.kenarlik),
      ),
      child: const Row(
        children: [
          Icon(Icons.hourglass_top_outlined, color: Renkler.metinIkincil, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'İş ortakları burada yakında listelenecek.',
              style: TextStyle(fontSize: 13, color: Renkler.metinIkincil),
            ),
          ),
        ],
      ),
    );
  }
}
