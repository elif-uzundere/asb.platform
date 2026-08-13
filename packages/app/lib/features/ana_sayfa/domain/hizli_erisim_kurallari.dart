// Ana sayfadaki "Hızlı Erişim" ızgarasının hangi modülleri gösterdiği ve
// hangilerinin ŞU AN gerçekten çalıştığı — saf Dart, Flutter import'u YOK.
//
// İZLENCEYE göre (docs/izlence-typescript-nestjs(1).md Bölüm 7) modüller
// fazlara yayılıyor: Faz 1'de sadece auth + banner + firma bitti, geri kalanı
// henüz backend'de bile yazılmadı. Bu yüzden ikonun görünmesi ile o modüle
// GERÇEKTEN gidilebilmesi ayrı şeyler — `rota` null ise widget "Yakında"
// gösterir, sahte bir sayfaya götürmez.

enum HizliErisimModulu {
  firmalar,
  harita,
  isIlanlari,
  ikinciElPazar,
  cookzone,
  paletTesisi,
  acilDurum,
  duyurular,
}

extension HizliErisimDurumu on HizliErisimModulu {
  String get etiket => switch (this) {
        HizliErisimModulu.firmalar => 'Firmalar',
        HizliErisimModulu.harita => 'Bölge İçi\nNavigasyon',
        HizliErisimModulu.isIlanlari => 'İş İlanları',
        HizliErisimModulu.ikinciElPazar => 'İkinci El\nPazar',
        HizliErisimModulu.cookzone => 'Cookzone',
        HizliErisimModulu.paletTesisi => 'Palet Tesisi',
        HizliErisimModulu.acilDurum => 'Acil Durum',
        HizliErisimModulu.duyurular => 'Duyurular',
      };

  /// null ise bu modül henüz yazılmadı — dokunulunca sadece "Yakında" gösterilir.
  ///
  /// `/firmalar`, `/duyurular` ve `/is-ilanlari` gerçek API'ye bağlı, girişsiz
  /// de erişilebilir (katalog modeli, bkz. docs/YENI-MODUL-REHBERI.md — yazma
  /// uçları `is-ilanlari`'nda ayrıca korumalı). `/harita` şimdilik backend'i
  /// olmayan bir placeholder ama rota gerçek. `/ikinci-el` şu an örnek ilan
  /// verileriyle çalışan frontend ekranıdır. `/acil-durum` ve `/palet-tesisi`
  /// Faz 3 modülleridir.
  String? get rota => switch (this) {
        HizliErisimModulu.firmalar => '/firmalar',
        HizliErisimModulu.harita => '/harita',
        HizliErisimModulu.duyurular => '/duyurular',
        HizliErisimModulu.isIlanlari => '/is-ilanlari',
        HizliErisimModulu.ikinciElPazar => '/ikinci-el',
        HizliErisimModulu.cookzone => '/cookzone',
        HizliErisimModulu.paletTesisi => '/palet-tesisi',
        HizliErisimModulu.acilDurum => '/acil-durum',
      };

  bool get aktif => rota != null;
}

/// Mockup'taki sırayla — 4'lü 2 satır.
const List<HizliErisimModulu> hizliErisimSirasi = [
  HizliErisimModulu.firmalar,
  HizliErisimModulu.harita,
  HizliErisimModulu.isIlanlari,
  HizliErisimModulu.ikinciElPazar,
  HizliErisimModulu.cookzone,
  HizliErisimModulu.paletTesisi,
  HizliErisimModulu.acilDurum,
  HizliErisimModulu.duyurular,
];