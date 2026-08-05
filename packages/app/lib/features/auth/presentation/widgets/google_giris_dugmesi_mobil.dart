// Android/iOS varyantı — kendi stilimizdeki dairesel buton, tıklanınca
// google_sign_in'in yerel (native) giriş akışını tetikler.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../durum/google_giris_notifier.dart';

class GoogleGirisDugmesi extends ConsumerWidget {
  const GoogleGirisDugmesi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sadece dinleyiciyi (authenticationEvents aboneliği) hayatta tutmak
    // için watch ediyoruz — web varyantıyla AYNI gerekçe.
    ref.watch(googleGirisNotifierProvider);

    return SosyalButon(
      icerik: const Text(
        'G',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Renkler.lacivert),
      ),
      basildi: () => ref.read(googleGirisNotifierProvider.notifier).tetikle(),
    );
  }
}
