// Hızlı erişim ızgarasının hangi modülleri "aktif" sayması gerektiğinin testi.
// Yeni bir modül gerçekten yazılıp rota eklendiğinde bu test bilerek kırılır
// — güncellenmesi gerektiğini hatırlatır.

import 'package:asb_app/features/ana_sayfa/domain/hizli_erisim_kurallari.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sadece gercekten yazilmis modullerin rotasi var', () {
    expect(HizliErisimModulu.firmalar.rota, '/firmalar');
    expect(HizliErisimModulu.harita.rota, '/harita');
    expect(HizliErisimModulu.duyurular.rota, '/duyurular');
    expect(HizliErisimModulu.isIlanlari.rota, '/is-ilanlari');
    expect(HizliErisimModulu.ikinciElPazar.rota, '/ikinci-el');
    expect(HizliErisimModulu.cookzone.rota, '/cookzone');
    expect(HizliErisimModulu.acilDurum.rota, '/acil-durum');
    expect(HizliErisimModulu.paletTesisi.rota, '/palet-tesisi');
  });

  test('henuz yazilmayan modul kalmadi (tumu aktif)', () {
    for (final modul in HizliErisimModulu.values) {
      expect(modul.rota, isNotNull, reason: '${modul.name} rotasi olmali');
      expect(modul.aktif, isTrue);
    }
  });

  test('aktif olan her modulun de aktif=true donmesi tutarli olmali', () {
    for (final modul in hizliErisimSirasi) {
      expect(modul.aktif, modul.rota != null);
    }
  });

  test('siralama mockuptaki 8 moduluin tamamini iceriyor', () {
    expect(hizliErisimSirasi.length, 8);
    expect(hizliErisimSirasi.toSet().length, 8); // tekrar yok
  });
}
