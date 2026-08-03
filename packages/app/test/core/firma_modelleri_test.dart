// Manuel mirror'ın (bkz. lib/core/models/firma_modelleri.dart) backend JSON'u
// ile uyumlu kaldığını doğrulayan küçük testler.

import 'package:asb_app/core/models/firma_modelleri.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FirmaResponse GET /firmalar/{id} govdesinden cozuluyor', () {
    final firma = FirmaResponse.jsondan({
      'id': 'f1',
      'ad': 'Ege Lojistik A.Ş.',
      'logoUrl': null,
      'sektor': 'Lojistik',
      'adres': 'Serbest Bölge, 3. Cadde No:12',
      'telefon': '02321234567',
      'eposta': 'info@egelojistik.com',
      'webAdres': null,
      'kurulusTarihi': null,
      'personelSayisi': null,
      'guncellemeTarihi': '2026-08-03T00:00:00.000Z',
    });

    expect(firma.id, 'f1');
    expect(firma.logoUrl, isNull);
    expect(firma.telefon, '02321234567');
  });

  test('telefon ve eposta null olabiliyor (backend nullable donuyor)', () {
    final firma = FirmaResponse.jsondan({
      'id': 'f2',
      'ad': 'Yeni Firma',
      'logoUrl': null,
      'sektor': 'Test',
      'adres': 'Test adres',
      'telefon': null,
      'eposta': null,
      'webAdres': null,
      'kurulusTarihi': null,
      'personelSayisi': null,
      'guncellemeTarihi': '2026-08-03T00:00:00.000Z',
    });

    expect(firma.telefon, isNull);
    expect(firma.eposta, isNull);
  });
}
