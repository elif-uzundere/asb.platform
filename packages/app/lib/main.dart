import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/yetkisiz_istek_akisi.dart';
import 'core/router/yonlendirici.dart';
import 'core/theme/renkler.dart';
import 'features/auth/presentation/durum/auth_durumu.dart';

void main() {
  runApp(const ProviderScope(child: AsbUygulamasi()));
}

class AsbUygulamasi extends ConsumerStatefulWidget {
  const AsbUygulamasi({super.key});

  @override
  ConsumerState<AsbUygulamasi> createState() => _AsbUygulamasiDurumu();
}

class _AsbUygulamasiDurumu extends ConsumerState<AsbUygulamasi> {
  StreamSubscription<void>? _yetkisizAbonelik;

  @override
  void initState() {
    super.initState();
    // 401 yanıtı (bkz. api_client.dart) buraya, provider grafiğinin
    // dışından geliyor — burada oturumu kapatıp girişe yönlendiriyoruz.
    _yetkisizAbonelik = yetkisizIstekAkisi.stream.listen((_) {
      ref.read(authProvider.notifier).cikisYap();
      ref.read(yonlendiriciProvider).go('/giris');
    });
  }

  @override
  void dispose() {
    _yetkisizAbonelik?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
