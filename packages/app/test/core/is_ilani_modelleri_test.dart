// Manuel mirror'ın (bkz. lib/core/models/is_ilani_modelleri.dart) backend
// JSON'u ile uyumlu kaldığını doğrulayan küçük testler.

import 'package:asb_app/core/models/is_ilani_modelleri.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('IsIlaniResponse GET /is-ilanlari/{id} govdesinden cozuluyor', () {
    final ilan = IsIlaniResponse.jsondan({
      'id': 'i1',
      'firmaId': 'f1',
      'firmaAdi': 'Ege Lojistik A.Ş.',
      'baslik': 'Depo Sorumlusu',
      'aciklama': 'Açıklama',
      'konum': '3. Cadde',
      'yayinTarihi': '2026-08-06T08:32:38.511Z',
      'durum': 'aktif',
    });

    expect(ilan.id, 'i1');
    expect(ilan.durum, IsIlaniDurumu.aktif);
    expect(ilan.konum, '3. Cadde');
  });

  test('konum null olabiliyor', () {
    final ilan = IsIlaniResponse.jsondan({
      'id': 'i1',
      'firmaId': 'f1',
      'firmaAdi': 'Test A.Ş.',
      'baslik': 'Başlık',
      'aciklama': 'Açıklama',
      'konum': null,
      'yayinTarihi': '2026-08-06T08:32:38.511Z',
      'durum': 'kapali',
    });

    expect(ilan.konum, isNull);
    expect(ilan.durum, IsIlaniDurumu.kapali);
  });

  test('taninmayan durum string i beklenmedik bir varsayilana degil, kapali ya cozulur', () {
    expect(IsIlaniDurumu.cozumle('bilinmeyen'), IsIlaniDurumu.kapali);
    expect(IsIlaniDurumu.cozumle(null), IsIlaniDurumu.kapali);
  });

  test('IsIlaniOlusturRequest konum bossa govdeye eklenmiyor', () {
    const dto = IsIlaniOlusturRequest(baslik: 'Başlık', aciklama: 'Açıklama', konum: '');
    expect(dto.jsonaDonustur().containsKey('konum'), isFalse);
  });

  test('IsIlaniOlusturRequest konum doluysa govdeye eklenir', () {
    const dto = IsIlaniOlusturRequest(baslik: 'Başlık', aciklama: 'Açıklama', konum: '3. Cadde');
    expect(dto.jsonaDonustur()['konum'], '3. Cadde');
  });

  test('IsBasvurusuResponse GET .../basvurular govdesinden cozuluyor', () {
    final basvuru = IsBasvurusuResponse.jsondan({
      'id': 'b1',
      'isIlaniId': 'i1',
      'kullaniciId': 'k1',
      'kullaniciAdSoyad': 'Ali Veli',
      'basvuruTarihi': '2026-08-06T08:32:52.264Z',
      'durum': 'beklemede',
      'cvUrl': '/uploads/cv.pdf',
    });

    expect(basvuru.kullaniciAdSoyad, 'Ali Veli');
    expect(basvuru.durum, IsBasvurusuDurumu.beklemede);
    expect(basvuru.cvUrl, '/uploads/cv.pdf');
  });

  test('IsBasvurusuResponse cvUrl null olabiliyor', () {
    final basvuru = IsBasvurusuResponse.jsondan({
      'id': 'b1',
      'isIlaniId': 'i1',
      'kullaniciId': 'k1',
      'kullaniciAdSoyad': 'Ali Veli',
      'basvuruTarihi': '2026-08-06T08:32:52.264Z',
      'durum': 'beklemede',
      'cvUrl': null,
    });

    expect(basvuru.cvUrl, isNull);
  });

  test('BasvurumResponse GET /is-ilanlari/basvurularim govdesinden cozuluyor', () {
    final basvurum = BasvurumResponse.jsondan({
      'id': 'b1',
      'isIlaniId': 'i1',
      'isIlaniBasligi': 'Depo Sorumlusu',
      'firmaAdi': 'Ege Lojistik A.Ş.',
      'basvuruTarihi': '2026-08-06T08:32:52.264Z',
      'durum': 'kabul',
      'cvUrl': null,
    });

    expect(basvurum.isIlaniBasligi, 'Depo Sorumlusu');
    expect(basvurum.firmaAdi, 'Ege Lojistik A.Ş.');
    expect(basvurum.durum, IsBasvurusuDurumu.kabul);
  });
}
