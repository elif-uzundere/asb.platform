// Saf Dart — flutter/dio/riverpod import ETMEZ (mimari kural 9). İş ilanı
// ekranlarındaki "bu buton görünsün mü/tıklanabilir mi" kararları burada
// yaşar, widget içinde if/else ile dağılmaz (mimari kural 10).

import '../../../core/models/auth_modelleri.dart';
import '../../../core/models/is_ilani_modelleri.dart';

/// Ziyaretçi bu ilana başvurabilir mi? İlan aktif olmalı VE kullanıcı
/// zaten kendi firmasının ilanına "başvuran" değil, "yöneten" taraf olmalı
/// (firma yetkilisi kendi ilanına başvuramaz — anlamsız olurdu).
bool basvuruYapilabilirMi(IsIlaniResponse ilan, KullaniciOzet? kullanici) {
  if (ilan.durum != IsIlaniDurumu.aktif) return false;
  if (kullanici == null) return false;
  return kullanici.firmaId != ilan.firmaId;
}

/// "Yeni İlan" formu sadece firma yetkilisine açılır — BR-2'nin (onaylı
/// firma şartı) UI karşılığı değil, backend zaten bunu reddediyor; bu
/// sadece anlamsız bir denemeyi baştan engelleyen bir UX kısayolu.
bool ilanOlusturulabilirMi(KullaniciOzet? kullanici) {
  return kullanici?.rol == KullaniciRolu.firmaYetkilisi;
}

/// Bu ilan, giriş yapmış kullanıcının kendi firmasına mı ait? "Başvurular"ı
/// görme ve "İlanı Kapat" butonlarının görünürlüğü buna bağlı — backend zaten
/// sahiplik kontrolü yapıyor (403 döner), bu sadece UI'da yanlış butonu hiç
/// göstermemek için.
bool ilanSahibiMi(IsIlaniResponse ilan, KullaniciOzet? kullanici) {
  return kullanici?.rol == KullaniciRolu.firmaYetkilisi && kullanici?.firmaId == ilan.firmaId;
}

String durumEtiketi(IsIlaniDurumu durum) => switch (durum) {
      IsIlaniDurumu.aktif => 'Aktif',
      IsIlaniDurumu.kapali => 'Kapalı',
    };

String basvuruDurumuEtiketi(IsBasvurusuDurumu durum) => switch (durum) {
      IsBasvurusuDurumu.beklemede => 'Beklemede',
      IsBasvurusuDurumu.incelendi => 'İncelendi',
      IsBasvurusuDurumu.reddedildi => 'Reddedildi',
      IsBasvurusuDurumu.kabul => 'Kabul Edildi',
    };

/// Firma yetkilisinin bir başvuruyu ilerletebileceği durumlar — mevcut durum
/// HARİÇ, `beklemede`'ye geri dönüş yok (backend de aynı kısıtı uyguluyor,
/// bkz. IsBasvurusuDurumGuncelleRequest).
List<IsBasvurusuKarari> basvuruIcinUygunKararlar(IsBasvurusuDurumu mevcutDurum) {
  return IsBasvurusuKarari.values.where((karar) => karar.deger != mevcutDurum.deger).toList();
}

String basvuruKarariEtiketi(IsBasvurusuKarari karar) => switch (karar) {
      IsBasvurusuKarari.incelendi => 'İncelendi İşaretle',
      IsBasvurusuKarari.reddedildi => 'Reddet',
      IsBasvurusuKarari.kabul => 'Kabul Et',
    };

/// `intl` paketine ihtiyaç duymayan minik biçimlendirici — firma_detay_ekrani
/// ile aynı gerekçe (tek yerde kullanılıyor, ayrı bağımlılığa değmedi).
String tarihiFormatla(DateTime tarih) {
  String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
  return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year}';
}
