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
  });

  test('henuz yazilmayan moduller rotasiz (Yakinda gosterir)', () {
    for (final modul in [
      HizliErisimModulu.isIlanlari,
      HizliErisimModulu.ikinciElPazar,
      HizliErisimModulu.cookzone,
      HizliErisimModulu.paletTesisi,
      HizliErisimModulu.acilDurum,
    ]) {
      expect(modul.rota, isNull, reason: '${modul.name} henuz aktif olmamali');
      expect(modul.aktif, isFalse);
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
