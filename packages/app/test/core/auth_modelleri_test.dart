// Manuel mirror'ın (bkz. lib/core/models/auth_modelleri.dart) backend JSON'u
// ile uyumlu kaldığını doğrulayan küçük testler.

import 'package:asb_app/core/models/auth_modelleri.dart';
import 'package:asb_app/core/models/banner_modelleri.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LoginResponse backend JSON zarfının data alanından çözülüyor', () {
    final sonuc = LoginResponse.jsondan({
      'accessToken': 'jwt-token',
      'kullanici': {
        'id': 'k1',
        'ad': 'Berzan',
        'soyad': 'Temel',
        'email': 'berzan@example.com',
        'rol': 'firma_yetkilisi',
        'firmaId': 'f1',
        'epostaDogrulandi': true,
      },
    });

    expect(sonuc.accessToken, 'jwt-token');
    expect(sonuc.kullanici.tamAd, 'Berzan Temel');
    expect(sonuc.kullanici.rol, KullaniciRolu.firmaYetkilisi);
    expect(sonuc.kullanici.firmaId, 'f1');
  });

  test('Bilinmeyen rol ziyaretci olarak çözülüyor', () {
    expect(KullaniciRolu.cozumle('yeni_rol'), KullaniciRolu.ziyaretci);
    expect(KullaniciRolu.cozumle(null), KullaniciRolu.ziyaretci);
  });

  test('KullaniciOzet JSON gidiş-dönüşü bozulmuyor', () {
    const kullanici = KullaniciOzet(
      id: 'k1',
      ad: 'Ali',
      soyad: 'Veli',
      email: 'ali@example.com',
      telefon: null,
      rol: KullaniciRolu.admin,
      firmaId: null,
      cookzoneIsletmeId: null,
      epostaDogrulandi: false,
    );

    final tekrar = KullaniciOzet.jsondan(kullanici.jsonaDonustur());

    expect(tekrar.id, kullanici.id);
    expect(tekrar.rol, KullaniciRolu.admin);
    expect(tekrar.firmaId, isNull);
    expect(tekrar.epostaDogrulandi, isFalse);
  });

  test('BannerResponse linkUrl null olabiliyor', () {
    final banner = BannerResponse.jsondan({
      'id': 'b1',
      'gorselUrl': 'http://localhost:3000/uploads/banner.png',
      'linkUrl': null,
      'sira': 2,
    });

    expect(banner.linkUrl, isNull);
    expect(banner.sira, 2);
  });

  test('RegisterRequest boş telefonu gövdeye eklemiyor', () {
    const dto = RegisterRequest(
      ad: 'Ali',
      soyad: 'Veli',
      email: 'ali@example.com',
      sifre: 'sifre1234',
      telefon: '',
    );

    expect(dto.jsonaDonustur().containsKey('telefon'), isFalse);
  });
}
