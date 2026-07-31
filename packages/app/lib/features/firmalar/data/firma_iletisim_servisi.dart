// Detay ekranındaki "Ara" / "E-posta" hızlı aksiyonlarının platform I/O'su.
// url_launcher burada kalır; widget doğrudan launchUrl çağırmaz — aynı desen
// ana_sayfa/data/banner_baglanti_servisi.dart'ta.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class FirmaIletisimServisi {
  const FirmaIletisimServisi();

  Future<bool> ara(String telefon) =>
      launchUrl(Uri(scheme: 'tel', path: telefon));

  Future<bool> epostaGonder(String eposta) =>
      launchUrl(Uri(scheme: 'mailto', path: eposta));

  Future<bool> webSitesiniAc(String webAdres) =>
      launchUrl(Uri.parse(webAdres), mode: LaunchMode.externalApplication);
}

final firmaIletisimServisiProvider =
    Provider<FirmaIletisimServisi>((ref) => const FirmaIletisimServisi());
