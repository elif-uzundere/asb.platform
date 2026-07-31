// Ana sayfadaki "Hızlı Erişim" ızgarasının hangi modülleri gösterdiği ve
// hangilerinin ŞU AN gerçekten çalıştığı — saf Dart, Flutter import'u YOK.
//
// İZLENCEYE göre (docs/izlence-typescript-nestjs(1).md Bölüm 7) modüller
// fazlara yayılıyor: Faz 1'de sadece auth + banner + firma bitti, geri kalanı
// henüz backend'de bile yazılmadı. Bu yüzden ikonun görünmesi ile o modüle
// GERÇEKTEN gidilebilmesi ayrı şeyler — `rota` null ise widget "Yakında"
// gösterir, sahte bir sayfaya götürmez (bkz. CLAUDE.md — "iş mantığı yok"
// yazan placeholder'lar dışında modül uydurulmaz).

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
  /// `/firmalar`, `/harita`, `/duyurular` zaten ShellRoute'ta gerçek ekranlara
  /// bağlı (harita/duyurular şimdilik kendi placeholder'ları, ama rota gerçek).
  String? get rota => switch (this) {
        HizliErisimModulu.firmalar => '/firmalar',
        HizliErisimModulu.harita => '/harita',
        HizliErisimModulu.duyurular => '/duyurular',
        HizliErisimModulu.isIlanlari => null,
        HizliErisimModulu.ikinciElPazar => null,
        HizliErisimModulu.cookzone => null,
        HizliErisimModulu.paletTesisi => null,
        HizliErisimModulu.acilDurum => null,
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
