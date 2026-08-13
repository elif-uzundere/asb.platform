// duyuru_gorseli.dart ile AYNI desen — kategoriye göre ikon/renk eşlemesi,
// liste/kart/çip arasında paylaşılan tek yer.

import 'package:flutter/material.dart';

import '../../../core/theme/renkler.dart';

({IconData ikon, Color renk}) kategoriGorseli(String? kategori) {
  switch (kategori) {
    case 'Ana Yemek':
      return (ikon: Icons.restaurant_outlined, renk: Renkler.lacivert);
    case 'Çorba':
      return (ikon: Icons.soup_kitchen_outlined, renk: const Color(0xFFD97706));
    case 'Başlangıç':
      return (ikon: Icons.tapas_outlined, renk: const Color(0xFF7C3AED));
    case 'Salata':
      return (ikon: Icons.eco_outlined, renk: const Color(0xFF16A34A));
    case 'Tostlar':
      return (ikon: Icons.bakery_dining_outlined, renk: const Color(0xFFB45309));
    case 'Hamburgerler':
      return (ikon: Icons.lunch_dining_outlined, renk: const Color(0xFFDC2626));
    case 'İçecek':
      return (ikon: Icons.local_cafe_outlined, renk: Renkler.mavi);
    case 'Tatlı':
      return (ikon: Icons.icecream_outlined, renk: const Color(0xFFDB2777));
    default:
      return (ikon: Icons.restaurant_menu_outlined, renk: Renkler.metinIkincil);
  }
}
