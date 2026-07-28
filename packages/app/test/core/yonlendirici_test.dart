// Router redirect kurallarının testi:
// oturumsuz kullanıcı korumalı rotalardan /giris'e atılmalı, açık rotalar
// (özellikle e-postadaki /sifre-sifirla derin linki) serbest kalmalı.

import 'package:asb_app/core/router/yonlendirici.dart';
import 'package:asb_app/core/storage/auth_depo.dart';
import 'package:asb_app/core/storage/guvenli_depo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Platform kanalı olmadan çalışan sahte güvenli depo.
class SahteDepo implements GuvenliDepo {
  SahteDepo([this._deger]);

  String? _deger;

  @override
  Future<String?> oku(String anahtar) async => _deger;

  @override
  Future<void> yaz(String anahtar, String deger) async => _deger = deger;

  @override
  Future<void> sil(String anahtar) async => _deger = null;
}

Future<void> uygulamayiKur(
  WidgetTester tester, {
  required String baslangicRotasi,
  required bool oturumAcik,
}) async {
  final depo = SahteDepo(
    oturumAcik
        ? '{"accessToken":"jwt","kullanici":${_kullaniciJson()}}'
        : null,
  );

  // Kabı elle kuruyoruz ki router'ı widget ağacından önce okuyup
  // başlangıç rotasını verebilelim.
  final kap = ProviderContainer(
    overrides: [guvenliDepoProvider.overrideWithValue(depo)],
  );
  addTearDown(kap.dispose);

  // Depodan okuma bitene kadar bekle (main.dart'taki `hazir` kapısı).
  await kap.read(authDepoProvider).oku();
  await tester.pump();

  final yonlendirici = kap.read(yonlendiriciProvider);
  yonlendirici.go(baslangicRotasi);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: kap,
      child: MaterialApp.router(routerConfig: yonlendirici),
    ),
  );
  await tester.pumpAndSettle();
}

String _kullaniciJson() =>
    '{"id":"k1","ad":"Elif","soyad":"Yilmaz","email":"elif@example.com",'
    '"rol":"ziyaretci","firmaId":null,"epostaDogrulandi":false}';

void main() {
  testWidgets('oturumsuz kullanıcı ana sayfadan /giris`e yönlendiriliyor',
      (tester) async {
    await uygulamayiKur(tester, baslangicRotasi: '/', oturumAcik: false);

    expect(find.text('Hoş geldiniz!'), findsOneWidget);
  });

  testWidgets('oturumsuz kullanıcı /sifre-sifirla derin linkine erişebiliyor '
      '(token`lı)', (tester) async {
    await uygulamayiKur(
      tester,
      baslangicRotasi: '/sifre-sifirla?token=abc123',
      oturumAcik: false,
    );

    expect(find.text('Yeni şifre belirle'), findsOneWidget);
    // Ham token kullanıcıya gösterilmiyor.
    expect(find.text('abc123'), findsNothing);
  });

  testWidgets('token`sız /sifre-sifirla giriş ekranına DÜŞMÜYOR, '
      'geçersiz link metni gösteriyor', (tester) async {
    await uygulamayiKur(
      tester,
      baslangicRotasi: '/sifre-sifirla',
      oturumAcik: false,
    );

    expect(find.text('Sıfırlama linki geçersiz'), findsOneWidget);
    expect(find.text('Hoş geldiniz!'), findsNothing);
  });

  testWidgets('oturumu açık kullanıcı /giris`ten ana sayfaya yönlendiriliyor',
      (tester) async {
    await uygulamayiKur(tester, baslangicRotasi: '/giris', oturumAcik: true);

    expect(find.text('Ana Sayfa'), findsWidgets);
  });
}
