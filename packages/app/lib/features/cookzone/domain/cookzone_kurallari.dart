// Saf Dart — flutter/dio/riverpod import ETMEZ (mimari kural 9). Sepet
// hesaplama, durum etiketleri, "ilerlet butonunun sırada ne göstereceği"
// gibi kararlar burada yaşar, widget içinde if/else ile dağılmaz.

import '../../../core/models/cookzone_modelleri.dart';

const List<CookzoneSiparisDurumu> _durumSirasi = [
  CookzoneSiparisDurumu.beklemede,
  CookzoneSiparisDurumu.alindi,
  CookzoneSiparisDurumu.hazirlaniyor,
  CookzoneSiparisDurumu.hazir,
  CookzoneSiparisDurumu.teslimEdildi,
];

String durumEtiketi(CookzoneSiparisDurumu durum) => switch (durum) {
      CookzoneSiparisDurumu.beklemede => 'Onay Bekliyor',
      CookzoneSiparisDurumu.alindi => 'Kabul Edildi',
      CookzoneSiparisDurumu.hazirlaniyor => 'Hazırlanıyor',
      CookzoneSiparisDurumu.hazir => 'Hazır',
      CookzoneSiparisDurumu.teslimEdildi => 'Teslim Edildi',
    };

/// Backend'deki `sonrakiDurum()` ile aynı sıra — cookzone_yetkilisi tarafında
/// "İlerlet" butonunun üstünde "sırada ne var" göstermek için.
CookzoneSiparisDurumu? sonrakiDurum(CookzoneSiparisDurumu durum) {
  final indeks = _durumSirasi.indexOf(durum);
  return indeks < _durumSirasi.length - 1 ? _durumSirasi[indeks + 1] : null;
}

/// Sırada gösterilecek aksiyon butonunun yazısı — `sonrakiDurum` null ise
/// (zaten teslim edildi) buton hiç gösterilmemeli, çağıran taraf onu kontrol eder.
String ilerletmeButonuEtiketi(CookzoneSiparisDurumu durum) => switch (sonrakiDurum(durum)) {
      CookzoneSiparisDurumu.alindi => 'Siparişi Kabul Et',
      CookzoneSiparisDurumu.hazirlaniyor => 'Hazırlanıyor Olarak İşaretle',
      CookzoneSiparisDurumu.hazir => 'Hazır Olarak İşaretle',
      CookzoneSiparisDurumu.teslimEdildi => 'Teslim Edildi Olarak İşaretle',
      // `sonrakiDurum` hiçbir zaman `beklemede` döndürmez (o zaten sıranın
      // başı) — derleyicinin bilmediği bu kısıt yüzünden bilerek yakalanan
      // "olmaz ama olursa boş dön" dalı.
      CookzoneSiparisDurumu.beklemede || null => '',
    };

/// Sepetteki toplam tutar — `menuOgesiId -> adet` haritasından, güncel
/// fiyatlarla hesaplanır. Backend'deki toplam hesaplama BR'sinin (siparişi
/// göndermeden ÖNCE, kullanıcıya anlık göstermek için) client-side karşılığı
/// — asıl geçerli hesap her zaman backend'de yapılır, bu sadece önizleme.
num sepetToplami(Map<String, int> sepet, List<CookzoneMenuOgesiResponse> menuOgeleri) {
  num toplam = 0;
  for (final oge in menuOgeleri) {
    final adet = sepet[oge.id] ?? 0;
    toplam += oge.fiyat * adet;
  }
  return toplam;
}

/// BR'nin (backend: `GecmisSaateSiparisVerilemezException`) client-side
/// önizlemesi — kullanıcıyı geçmiş bir saat seçtiğinde backend'e gitmeden
/// uyarmak için. Asıl kontrol yine backend'de.
bool alinmaSaatiGecerliMi(DateTime alinmaSaati) => alinmaSaati.isAfter(DateTime.now());

String tarihSaatiFormatla(DateTime tarih) {
  String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
  return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year} ${ikiHane(tarih.hour)}:${ikiHane(tarih.minute)}';
}
