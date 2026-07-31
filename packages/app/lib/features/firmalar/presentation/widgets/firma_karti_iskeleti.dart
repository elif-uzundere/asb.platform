// Yükleniyor durumunda gösterilen soluk kart — spinner yerine. Modern
// uygulamalarda liste yüklenirken kartın şeklini önceden göstermek, boş bir
// dönen çark göstermekten daha az "sıçrama" hissi verir.
//
// Gerçek FirmaKarti'yle aynı gölge/köşe stiline sahip — iskelet ile gerçek
// içerik arasında ani bir sıçrama olmasın diye.

import 'package:flutter/material.dart';

import '../../../../core/theme/renkler.dart';

class FirmaKartiIskeleti extends StatelessWidget {
  const FirmaKartiIskeleti({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Renkler.lacivert.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _kutu(48, 48, sekil: BoxShape.circle),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kutu(140, 14),
                const SizedBox(height: 8),
                _kutu(70, 12),
                const SizedBox(height: 8),
                _kutu(180, 11),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kutu(double genislik, double yukseklik, {BoxShape sekil = BoxShape.rectangle}) {
    return Container(
      width: genislik,
      height: yukseklik,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        shape: sekil,
        borderRadius: sekil == BoxShape.rectangle ? BorderRadius.circular(4) : null,
      ),
    );
  }
}
