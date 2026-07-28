import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/yonlendirici.dart';
import 'core/theme/renkler.dart';

void main() {
  runApp(const ProviderScope(child: AsbUygulamasi()));
}

class AsbUygulamasi extends ConsumerWidget {
  const AsbUygulamasi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Oturum güvenli depodan okunana kadar AYRI bir MaterialApp göstermiyoruz:
    // router'sız bir MaterialApp kendi Navigator'ını kurup web'de tarayıcı
    // adresini '/' olarak yeniden yazıyor ve e-postadaki
    // /sifre-sifirla?token=... derin linki daha router görmeden kayboluyor.
    // Bekleme göstergesi bunun yerine kabuğun (SekmeKabugu) içinde.
    return MaterialApp.router(
      title: 'ASB Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Renkler.lacivert,
          primary: Renkler.lacivert,
          secondary: Renkler.mavi,
        ),
        scaffoldBackgroundColor: Renkler.beyaz,
      ),
      routerConfig: ref.watch(yonlendiriciProvider),
    );
  }
}
