// Liste ve detay ekranı arasında paylaşılan tek yer — kategoriye göre
// ikon/renk eşlemesi. Dart'ta alt çizgili isimler DOSYAYA özel (sınıfa değil),
// bu yüzden iki ekranın da kullanabilmesi için burada, isim alt çizgisiz.

import 'package:flutter/material.dart';

import '../../../core/theme/renkler.dart';

({IconData ikon, Color renk}) kategoriGorseli(String? kategori) {
  switch (kategori) {
    case 'Bakım':
      return (ikon: Icons.build_outlined, renk: const Color(0xFFD97706));
    case 'Genel':
      return (ikon: Icons.info_outline, renk: Renkler.mavi);
    default:
      return (ikon: Icons.campaign_outlined, renk: Renkler.lacivert);
  }
}
