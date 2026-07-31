// Firma modülünün saf kuralları — Flutter/dio/riverpod import'u YOK.
// Backend'e hiç gitmeden, widget hiç kurulmadan test edilebilir olmaları
// bu yüzden — bkz. docs/CLAUDE.md mimari kural 9.

import '../../../core/models/firma_modelleri.dart';

/// Firma listesi/arama isteğinin sorgu parametreleri.
///
/// Ayrı bir sınıf olmasının sebebi: ekran sadece kullanıcının yazdığı ham
/// metni tutar, "boş string mi göndereyim yoksa parametreyi hiç mi eklemeyeyim"
/// kararını burada saf bir fonksiyona bırakır — widget'ta if/else olmaz.
class FirmaSorgusu {
  const FirmaSorgusu({this.arama, this.sektor});

  final String? arama;
  final String? sektor;

  /// dio'nun `queryParameters`'ına doğrudan verilebilecek şekil.
  /// Boş/null alanlar haritaya HİÇ girmiyor — `?arama=&sektor=` gibi anlamsız
  /// sorgu string'leri oluşmasın diye.
  Map<String, dynamic> sorguParametreleri() => {
        if (arama != null && arama!.trim().isNotEmpty) 'arama': arama!.trim(),
        if (sektor != null && sektor!.isNotEmpty) 'sektor': sektor,
      };
}

extension FirmaGorunumu on FirmaResponse {
  /// Logo yoksa gösterilecek baş harfler. Kart ve detayda aynı mantık
  /// kullanılsın diye tek yerde — iki yerde ayrı ayrı yazılan "ilk harfi al"
  /// kodu er ya da geç birbirinden sapar.
  String get basHarfler {
    final kelimeler = ad.trim().split(RegExp(r'\s+'));
    if (kelimeler.isEmpty || kelimeler.first.isEmpty) return '?';
    if (kelimeler.length == 1) return kelimeler.first[0].toUpperCase();
    return (kelimeler.first[0] + kelimeler[1][0]).toUpperCase();
  }

  /// Baş harf avatarının rengi. Firma adından türetilir — aynı firma her
  /// zaman aynı rengi alır (kullanıcı listede/detayda tutarlılık hisseder),
  /// ama farklı firmalar görsel olarak ayrışır.
  int get avatarRengiIndeksi => ad.hashCode.abs() % 6;
}
