// Kaynak: eski Expo app/(tabs)/index.tsx
// (silindi — bkz. izlence Ek A)
//
// Mockup'taki "Hızlı Erişim" ızgarası burada eklendi. Her ikonun aktif olup
// olmadığı, domain/hizli_erisim_kurallari.dart dosyasında tutuluyor.
// Bu dosya yalnızca ana sayfanın görünümünü oluşturuyor.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';
import '../../../is_ortaklari/presentation/widgetlar/is_ortaklari_bolumu.dart';
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
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 10,
            bottom: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BannerCarousel(),

              const _BolumBasligi('Hızlı Erişim'),

              const HizliErisimIzgarasi(),

              const SizedBox(height: 8),

              const _BolumBasligi(
                'Öne Çıkanlar ve İş Ortakları',
              ),

              DuyurularHizliErisimKarti(
                onTap: () {
                  context.go('/duyurular');
                },
              ),

              const SizedBox(height: 12),

              const IsOrtaklariBolumu(),
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
      padding: const EdgeInsets.only(
        top: 12,
        bottom: 8,
      ),
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