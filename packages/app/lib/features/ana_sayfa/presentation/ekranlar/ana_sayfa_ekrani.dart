// Kaynak: eski Expo app/(tabs)/index.tsx (silindi — bkz. docs/izlence-typescript-nestjs(1).md Ek A)

import 'package:flutter/material.dart';

import '../widgets/banner_carousel.dart';

class AnaSayfaEkrani extends StatelessWidget {
  const AnaSayfaEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              BannerCarousel(),
              Text(
                'Ana Sayfa - banner, duyuru ve iş ortakları burada listelenecek.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
