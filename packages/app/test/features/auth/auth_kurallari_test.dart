// Auth domain kuralları — saf fonksiyonlar, widget/ağ gerekmiyor.

import 'package:asb_app/features/auth/domain/auth_kurallari.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sifirlamaTokeniGecerli', () {
    test('token yoksa geçersiz', () {
      expect(sifirlamaTokeniGecerli(null), isFalse);
      expect(sifirlamaTokeniGecerli(''), isFalse);
    });

    test('sadece boşluktan oluşan token geçersiz', () {
      expect(sifirlamaTokeniGecerli('   '), isFalse);
    });

    test('dolu token geçerli', () {
      expect(sifirlamaTokeniGecerli('eyJhbGciOi'), isTrue);
    });
  });

  group('girdiyiTemizle', () {
    test('baştaki ve sondaki boşlukları atar', () {
      expect(girdiyiTemizle('  elif@example.com  '), 'elif@example.com');
    });
  });

  group('opsiyonelGirdi', () {
    test('boş/boşluk girdi null döner (alan gönderilmez)', () {
      expect(opsiyonelGirdi(''), isNull);
      expect(opsiyonelGirdi('   '), isNull);
    });

    test('dolu girdi temizlenmiş hâliyle döner', () {
      expect(opsiyonelGirdi(' 05551112233 '), '05551112233');
    });
  });
}
