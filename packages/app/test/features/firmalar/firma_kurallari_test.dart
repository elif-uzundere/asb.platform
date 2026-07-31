// Firma domain kuralları — baş harfler, avatar rengi, sorgu parametreleri.

import 'package:asb_app/core/models/firma_modelleri.dart';
import 'package:asb_app/features/firmalar/domain/firma_kurallari.dart';
import 'package:flutter_test/flutter_test.dart';

FirmaResponse _firma(String ad) => FirmaResponse(
      id: 'f1',
      ad: ad,
      logoUrl: null,
      sektor: 'Lojistik',
      adres: 'Serbest Bölge',
      telefon: null,
      eposta: null,
      webAdres: null,
      kurulusTarihi: null,
      personelSayisi: null,
      guncellemeTarihi: DateTime(2026, 1, 1),
    );

void main() {
  group('basHarfler', () {
    test('iki kelimeli ad ilk iki kelimenin baş harflerini alır', () {
      expect(_firma('Ege Lojistik').basHarfler, 'EL');
    });

    test('tek kelimeli ad tek harf verir', () {
      expect(_firma('Trendyol').basHarfler, 'T');
    });

    test('küçük harfle yazılan ad büyük harfe çevrilir', () {
      expect(_firma('ege lojistik').basHarfler, 'EL');
    });

    test('baştaki/sondaki boşluklar yok sayılır', () {
      expect(_firma('  Ege Lojistik  ').basHarfler, 'EL');
    });
  });

  group('avatarRengiIndeksi', () {
    test('aynı ad her zaman aynı indeksi verir (tutarlılık)', () {
      final birinci = _firma('Ege Lojistik').avatarRengiIndeksi;
      final ikinci = _firma('Ege Lojistik').avatarRengiIndeksi;
      expect(birinci, ikinci);
    });

    test('indeks her zaman 0-5 aralığında (6 renklik palet)', () {
      for (final ad in ['A', 'Bir Firma', 'Uzun İsimli Bir Firma A.Ş.']) {
        expect(_firma(ad).avatarRengiIndeksi, inInclusiveRange(0, 5));
      }
    });
  });

  group('FirmaSorgusu.sorguParametreleri', () {
    test('boş/null alanlar haritaya hiç girmiyor', () {
      const bos = FirmaSorgusu();
      expect(bos.sorguParametreleri(), isEmpty);

      const bosMetin = FirmaSorgusu(arama: '   ', sektor: '');
      expect(bosMetin.sorguParametreleri(), isEmpty);
    });

    test('arama metni trim edilip eklenir', () {
      const sorgu = FirmaSorgusu(arama: '  ege  ');
      expect(sorgu.sorguParametreleri(), {'arama': 'ege'});
    });

    test('sektör doluysa eklenir', () {
      const sorgu = FirmaSorgusu(sektor: 'Tekstil');
      expect(sorgu.sorguParametreleri(), {'sektor': 'Tekstil'});
    });

    test('ikisi birden doluysa ikisi de eklenir', () {
      const sorgu = FirmaSorgusu(arama: 'ege', sektor: 'Lojistik');
      expect(sorgu.sorguParametreleri(), {'arama': 'ege', 'sektor': 'Lojistik'});
    });
  });
}
