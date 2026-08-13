// Manuel mirror'ın (bkz. lib/core/models/cookzone_modelleri.dart) backend
// JSON'u ile uyumlu kaldığını doğrulayan küçük testler.

import 'package:asb_app/core/models/cookzone_modelleri.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CookzoneIsletmeResponse GET /cookzone/isletmeler/{id} govdesinden cozuluyor', () {
    final isletme = CookzoneIsletmeResponse.jsondan({
      'id': 'i1',
      'ad': 'Ana Kafeterya',
      'bolgeNoktasiAdi': 'Ana Kafeterya',
      'menuOgeleri': [
        {'id': 'm1', 'ad': 'Izgara Tavuk Menü', 'aciklama': 'Pilav ile', 'fiyat': 95, 'kategori': 'Ana Yemek'},
        {'id': 'm2', 'ad': 'Ayran', 'aciklama': null, 'fiyat': 15, 'kategori': 'İçecek'},
      ],
    });

    expect(isletme.ad, 'Ana Kafeterya');
    expect(isletme.menuOgeleri, hasLength(2));
    expect(isletme.menuOgeleri[1].aciklama, isNull);
  });

  test('taninmayan durum string i beklenmedik bir varsayilana degil, beklemede ye cozulur', () {
    expect(CookzoneSiparisDurumu.cozumle('bilinmeyen'), CookzoneSiparisDurumu.beklemede);
    expect(CookzoneSiparisDurumu.cozumle(null), CookzoneSiparisDurumu.beklemede);
  });

  test('CookzoneSiparisResponse GET /cookzone/siparislerim govdesinden cozuluyor', () {
    final siparis = CookzoneSiparisResponse.jsondan({
      'id': 's1',
      'isletmeId': 'i1',
      'isletmeAdi': 'Ana Kafeterya',
      'durum': 'hazir',
      'toplamTutar': 205,
      'alinmaSaati': '2026-08-12T14:00:00.000Z',
      'olusturmaTarihi': '2026-08-11T06:42:01.965Z',
      'kalemler': [
        {'id': 'k1', 'menuOgesiAdi': 'Izgara Tavuk Menü', 'adet': 2, 'birimFiyat': 95},
      ],
    });

    expect(siparis.durum, CookzoneSiparisDurumu.hazir);
    expect(siparis.toplamTutar, 205);
    expect(siparis.kalemler.single.adet, 2);
  });

  test('CookzoneSiparisOlusturRequest govdeye dogru donusuyor', () {
    const dto = CookzoneSiparisOlusturRequest(
      isletmeId: 'i1',
      alinmaSaati: '2026-08-12T14:00:00.000Z',
      kalemler: [CookzoneSiparisKalemiRequest(menuOgesiId: 'm1', adet: 2)],
    );

    final govde = dto.jsonaDonustur();

    expect(govde['isletmeId'], 'i1');
    expect((govde['kalemler'] as List).single, {'menuOgesiId': 'm1', 'adet': 2});
  });
}
