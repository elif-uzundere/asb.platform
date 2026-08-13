import 'package:asb_app/core/models/cookzone_modelleri.dart';
import 'package:asb_app/features/cookzone/domain/cookzone_kurallari.dart';
import 'package:flutter_test/flutter_test.dart';

CookzoneMenuOgesiResponse _oge(String id, num fiyat) =>
    CookzoneMenuOgesiResponse(id: id, ad: 'Ürün $id', aciklama: null, fiyat: fiyat, kategori: 'Ana Yemek');

void main() {
  group('sonrakiDurum', () {
    test('durum sirasi atlanamaz, hep bir sonrakini doner', () {
      expect(sonrakiDurum(CookzoneSiparisDurumu.beklemede), CookzoneSiparisDurumu.alindi);
      expect(sonrakiDurum(CookzoneSiparisDurumu.alindi), CookzoneSiparisDurumu.hazirlaniyor);
      expect(sonrakiDurum(CookzoneSiparisDurumu.hazirlaniyor), CookzoneSiparisDurumu.hazir);
      expect(sonrakiDurum(CookzoneSiparisDurumu.hazir), CookzoneSiparisDurumu.teslimEdildi);
    });

    test('teslim edildi sondur, sonraki durum yoktur', () {
      expect(sonrakiDurum(CookzoneSiparisDurumu.teslimEdildi), isNull);
    });
  });

  group('ilerletmeButonuEtiketi', () {
    test('her durum icin dogru buton yazisini doner', () {
      expect(ilerletmeButonuEtiketi(CookzoneSiparisDurumu.beklemede), 'Siparişi Kabul Et');
      expect(ilerletmeButonuEtiketi(CookzoneSiparisDurumu.hazir), 'Teslim Edildi Olarak İşaretle');
    });

    test('teslim edildi icin bos yazi doner (buton gosterilmemeli)', () {
      expect(ilerletmeButonuEtiketi(CookzoneSiparisDurumu.teslimEdildi), '');
    });
  });

  group('sepetToplami', () {
    test('sepetteki her urun adet x fiyat olarak toplanir', () {
      final menu = [_oge('m1', 95), _oge('m2', 15)];
      final toplam = sepetToplami({'m1': 2, 'm2': 1}, menu);

      expect(toplam, 205);
    });

    test('bos sepet 0 doner', () {
      expect(sepetToplami({}, [_oge('m1', 95)]), 0);
    });
  });

  group('alinmaSaatiGecerliMi', () {
    test('gelecekteki bir saat gecerlidir', () {
      expect(alinmaSaatiGecerliMi(DateTime.now().add(const Duration(hours: 1))), isTrue);
    });

    test('gecmisteki bir saat gecersizdir', () {
      expect(alinmaSaatiGecerliMi(DateTime.now().subtract(const Duration(hours: 1))), isFalse);
    });
  });
}
