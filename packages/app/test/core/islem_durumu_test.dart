// FormNotifier tabanı — tüm form akışları buna dayandığı için davranışı kilitli.

import 'package:asb_app/core/durum/islem_durumu.dart';
import 'package:asb_app/core/network/api_hata.dart';
import 'package:flutter_test/flutter_test.dart';

class _DenemeNotifier extends FormNotifier {
  int cagriSayisi = 0;

  Future<void> gonder(Future<void> Function() islem) => calistir(() async {
        cagriSayisi++;
        await islem();
      });
}

void main() {
  test('başarılı işlem: suruyor → basarili', () async {
    final notifier = _DenemeNotifier();
    expect(notifier.state, isA<IslemBosta>());

    final gelecek = notifier.gonder(() async {});
    expect(notifier.state, isA<IslemSuruyor>());

    await gelecek;
    expect(notifier.state, isA<IslemBasarili>());
  });

  test('ApiHata yakalanıp mesajıyla birlikte durumda taşınıyor', () async {
    final notifier = _DenemeNotifier();

    await notifier.gonder(() async => throw const ApiHata('Şifre hatalı'));

    expect(notifier.state, isA<IslemHatali>());
    expect((notifier.state as IslemHatali).mesaj, 'Şifre hatalı');
  });

  test('istek sürerken ikinci gönderim yok sayılıyor (çift tıklama)', () async {
    final notifier = _DenemeNotifier();

    final ilk = notifier.gonder(() => Future<void>.delayed(Duration.zero));
    final ikinci = notifier.gonder(() async {});
    await Future.wait([ilk, ikinci]);

    expect(notifier.cagriSayisi, 1);
  });

  test('sifirla durumu boşa çeker', () async {
    final notifier = _DenemeNotifier();
    await notifier.gonder(() async {});

    notifier.sifirla();

    expect(notifier.state, isA<IslemBosta>());
  });

  test('ApiHata dışındaki hatalar yutulmuyor', () async {
    final notifier = _DenemeNotifier();

    await expectLater(
      notifier.gonder(() async => throw StateError('beklenmeyen')),
      throwsA(isA<StateError>()),
    );
  });
}
