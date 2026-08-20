// Saf Dart, flutter/dio/riverpod import etmez (mimari kural 9).
//
// "Öne Çıkanlar" bölümü artık sadece duyurulardan değil, admin panelinden
// "öne çıkan" işaretlenmiş İkinci El ilanlarından da besleniyor. İki farklı
// kaynağı tek bir ortak görünüm modeline indirgiyor ki widget kaynak
// ayrımıyla uğraşmasın.

enum OneCikanTuru { duyuru, ikinciEl }

class OneCikanOgesi {
  const OneCikanOgesi({
    required this.tur,
    required this.baslik,
    required this.altBaslik,
    required this.tarih,
    required this.hedefId,
    this.kategori,
  });

  final OneCikanTuru tur;
  final String baslik;

  /// Duyuruda tarih, ikinci elde fiyat — gösterim satırı önceden biçimlenmiş
  /// olarak gelir, widget kaynak türüne göre dallanmaz.
  final String altBaslik;
  final DateTime tarih;

  /// Duyuruda `/duyurular/:id`ye, ikinci elde `/ikinci-el/:id`ye gidilir —
  /// hangi rotanın kullanılacağına widget `tur`e bakarak karar verir.
  final String hedefId;

  /// Sadece duyuru türünde dolu — ikon/renk eşlemesi için (bkz. duyuru_gorseli.dart).
  final String? kategori;
}
