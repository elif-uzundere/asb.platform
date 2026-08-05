// Yardım ve Destek ekranındaki telefon/e-posta aksiyonlarının platform I/O'su.
// Aynı desen: ana_sayfa/data/footer_iletisim_servisi.dart, firma_iletisim_servisi.dart
// — url_launcher burada kalır, widget doğrudan çağırmaz.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class DestekIletisimServisi {
  const DestekIletisimServisi();

  Future<bool> ara(String telefon) =>
      launchUrl(Uri(scheme: 'tel', path: telefon.replaceAll(' ', '')));

  Future<bool> epostaGonder(String eposta) =>
      launchUrl(Uri(scheme: 'mailto', path: eposta));
}

final destekIletisimServisiProvider =
    Provider<DestekIletisimServisi>((ref) => const DestekIletisimServisi());
