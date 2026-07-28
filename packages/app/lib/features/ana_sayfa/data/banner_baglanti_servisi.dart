// Banner'a tıklanınca adresin açılması. url_launcher (platform I/O) bu
// katmanda kalır; widget doğrudan `launchUrl` çağırmaz.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/banner_modelleri.dart';
import '../domain/banner_kurallari.dart';

class BannerBaglantiServisi {
  const BannerBaglantiServisi();

  /// Banner tıklanabilir değilse ya da adres açılamadıysa `false` döner.
  Future<bool> bannerAc(BannerResponse banner) async {
    final adres = banner.baglanti;
    if (adres == null) return false;
    return launchUrl(adres, mode: LaunchMode.externalApplication);
  }
}

final bannerBaglantiServisiProvider =
    Provider<BannerBaglantiServisi>((ref) => const BannerBaglantiServisi());
