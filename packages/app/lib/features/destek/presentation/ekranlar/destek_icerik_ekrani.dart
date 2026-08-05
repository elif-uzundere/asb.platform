// Yardım ve Destek'teki statik bilgi sayfaları (Güvenlik, Sık Sorular vb.)
// için TEK bir genel ekran — her konu için ayrı dosya açmaya gerek yok,
// içerik domain/destek_icerikleri.dart'ta anahtarla tutuluyor.

import 'package:flutter/material.dart';

import '../../../../core/theme/renkler.dart';
import '../../domain/destek_icerikleri.dart';

class DestekIcerikEkrani extends StatelessWidget {
  const DestekIcerikEkrani({super.key, required this.anahtar});

  final String anahtar;

  @override
  Widget build(BuildContext context) {
    final icerik = destekIcerikleri[anahtar];

    return Scaffold(
      backgroundColor: Renkler.beyaz,
      appBar: AppBar(
        title: Text(icerik?.baslik ?? 'İçerik'),
        backgroundColor: Renkler.beyaz,
        foregroundColor: Renkler.lacivert,
        elevation: 0,
      ),
      body: icerik == null
          ? const Center(child: Text('İçerik bulunamadı.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final paragraf in icerik.paragraflar) ...[
                    Text(
                      paragraf,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Renkler.lacivert,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
    );
  }
}
