// Banner modülünün saf kuralları — Flutter/dio/url_launcher import'u YOK.

import '../../../core/models/banner_modelleri.dart';

extension BannerBaglantisi on BannerResponse {
  /// Banner'ın açılabilir adresi. Kural:
  /// - `linkUrl` boş/null ise banner tıklanabilir değil
  /// - sadece mutlak http/https adresleri açılır (`javascript:` gibi
  ///   şemalar ve göreli yollar reddedilir)
  Uri? get baglanti {
    final ham = linkUrl?.trim();
    if (ham == null || ham.isEmpty) return null;

    final adres = Uri.tryParse(ham);
    if (adres == null || !adres.hasAuthority) return null;
    if (adres.scheme != 'http' && adres.scheme != 'https') return null;

    return adres;
  }

  bool get tiklanabilir => baglanti != null;
}
