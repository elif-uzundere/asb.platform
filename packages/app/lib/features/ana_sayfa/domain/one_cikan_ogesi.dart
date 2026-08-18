// Saf Dart — flutter/dio/riverpod import ETMEZ (mimari kural 9).
//
// "Öne Çıkanlar" bölümü artık sadece duyurulardan değil, admin panelinden
// "öne çıkan" işaretlenmiş İkinci El ilanlarından da besleniyor
// (18.08.2026, Berzan'ın isteği) — iki farklı kaynağı tek bir ortak
// görünüm modeline indirgiyor ki widget kaynak ayrımıyla uğraşmasın.

enum OneCikanTuru { duyuru, ikinciEl }

class OneCikanOgesi {
  const OneCikanOgesi({
    required this.tur,
    required this.baslik,
    required this.altBaslik,
    required this.tarih,
    this.kategori,
    this.duyuruId,
  });

  final OneCikanTuru tur;
  final String baslik;

  /// Duyuruda tarih, ikinci elde fiyat — gösterim satırı önceden biçimlenmiş
  /// olarak gelir, widget kaynak türüne göre dallanmaz.
  final String altBaslik;
  final DateTime tarih;

  /// Sadece duyuru türünde dolu — ikon/renk eşlemesi için (bkz. duyuru_gorseli.dart).
  final String? kategori;

  /// Sadece duyuru türünde dolu — dokununca `/duyurular/:id`ye gidilir.
  /// İkinci el ilanının henüz ayrı bir detay ekranı yok, listeye gidilir.
  final String? duyuruId;
}
