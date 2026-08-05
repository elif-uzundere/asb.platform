// Web varyantı — Google Identity Services'in KENDİ ürettiği düğme
// (google_sign_in_web/web_only.dart). Tıklama akışını Google yönetiyor,
// biz sadece sonucu google_giris_notifier.dart'taki authenticationEvents
// aboneliğiyle yakalıyoruz (bkz. bu dosyanın ref.watch satırı).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

import '../durum/google_giris_notifier.dart';

class GoogleGirisDugmesi extends ConsumerWidget {
  const GoogleGirisDugmesi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider'ı (ve içindeki authenticationEvents aboneliğini) bu widget
    // ekranda kaldığı sürece canlı tutar — buton kendi kendine tıklanabilir
    // olsa da SONUCU dinleyen taraf bu olmadan hiç kurulmaz.
    ref.watch(googleGirisNotifierProvider);

    // 38x38'lik dairemize zorla sıkıştırmıyoruz — Google'ın kendi ikon
    // butonu (medium ~32-40px) bunun için yeterince küçük zaten, ama
    // içindeki metin/ikonun kırpılmaması için biraz nefes payı bırakıyoruz.
    return SizedBox(
      width: 46,
      height: 40,
      child: web.renderButton(
        configuration: web.GSIButtonConfiguration(
          type: web.GSIButtonType.icon,
          shape: web.GSIButtonShape.pill,
          size: web.GSIButtonSize.medium,
        ),
      ),
    );
  }
}
