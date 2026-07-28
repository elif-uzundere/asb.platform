// Banner domain kuralları — hangi banner tıklanabilir?

import 'package:asb_app/core/models/banner_modelleri.dart';
import 'package:asb_app/features/ana_sayfa/domain/banner_kurallari.dart';
import 'package:flutter_test/flutter_test.dart';

BannerResponse _banner(String? link) =>
    BannerResponse(id: 'b1', gorselUrl: 'http://x/y.png', linkUrl: link, sira: 1);

void main() {
  test('linkUrl null ise tıklanabilir değil', () {
    expect(_banner(null).tiklanabilir, isFalse);
    expect(_banner(null).baglanti, isNull);
  });

  test('boş/boşluk linkUrl tıklanabilir değil', () {
    expect(_banner('').tiklanabilir, isFalse);
    expect(_banner('   ').tiklanabilir, isFalse);
  });

  test('http ve https adresleri açılabilir', () {
    expect(_banner('http://example.com/kampanya').tiklanabilir, isTrue);
    expect(_banner('https://example.com/kampanya').tiklanabilir, isTrue);
  });

  test('göreli yol açılmaz (mutlak adres şartı)', () {
    expect(_banner('/kampanya').tiklanabilir, isFalse);
  });

  test('http(s) dışı şemalar reddedilir', () {
    expect(_banner('javascript:alert(1)').tiklanabilir, isFalse);
    expect(_banner('file:///etc/passwd').tiklanabilir, isFalse);
  });

  test('adresin başındaki/sonundaki boşluk temizlenir', () {
    expect(_banner('  https://example.com  ').baglanti.toString(),
        'https://example.com');
  });
}
