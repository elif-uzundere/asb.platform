// Footer'daki telefon/e-posta aksiyonlarının platform I/O'su. Aynı desen:
// firma_iletisim_servisi.dart / banner_baglanti_servisi.dart — url_launcher
// burada kalır, widget doğrudan çağırmaz.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterIletisimServisi {
  const FooterIletisimServisi();

  /// Görüntülenen numarada boşluk var ("+90 282 265 10 00") ama tel: URI'si
  /// bunu kabul etmiyor — arama sırasında temizleniyor.
  Future<bool> ara(String telefon) =>
      launchUrl(Uri(scheme: 'tel', path: telefon.replaceAll(' ', '')));

  Future<bool> epostaGonder(String eposta) =>
      launchUrl(Uri(scheme: 'mailto', path: eposta));

  Future<bool> sosyalMedyayiAc(String adres) =>
      launchUrl(Uri.parse(adres), mode: LaunchMode.externalApplication);
}

final footerIletisimServisiProvider =
    Provider<FooterIletisimServisi>((ref) => const FooterIletisimServisi());
