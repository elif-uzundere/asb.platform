// Kaynak: packages/shared-types/src/firma.types.ts
// Manuel mirror — bkz. lib/core/models/auth_modelleri.dart başındaki not.
//
// `FirmaOnayKuyrugu` ve `FirmaOlusturRequest` BİLEREK burada yok — bunlar
// sadece admin akışına ait, Flutter'da admin ekranı henüz yok (AdminJS kararı
// netleşmedi, bkz. docs/CLAUDE.md). Admin ekranı yazılınca eklenecek.

/// TS: `interface FirmaResponse` — GET /firmalar ve GET /firmalar/{id}'nin
/// `data` alanı. `onayDurumu` ve `aktif` backend'de BİLEREK yok — bu zaten
/// sadece onaylı+aktif firmaları döndüren bir endpoint, iç durum sızmıyor.
class FirmaResponse {
  const FirmaResponse({
    required this.id,
    required this.ad,
    required this.logoUrl,
    required this.sektor,
    required this.adres,
    required this.telefon,
    required this.eposta,
    required this.webAdres,
    required this.kurulusTarihi,
    required this.personelSayisi,
    required this.guncellemeTarihi,
  });

  final String id;
  final String ad;
  final String? logoUrl;
  final String sektor;
  final String adres;
  final String? telefon;
  final String? eposta;
  final String? webAdres;
  // TS tarafında ISO string ("2018-03-15"); burada gösterim/karşılaştırma
  // kolay olsun diye DateTime'a çevriliyor — tek dönüşüm noktası burası.
  final DateTime? kurulusTarihi;
  final int? personelSayisi;
  final DateTime guncellemeTarihi;

  factory FirmaResponse.jsondan(Map<String, dynamic> json) => FirmaResponse(
        id: json['id'] as String,
        ad: json['ad'] as String,
        logoUrl: json['logoUrl'] as String?,
        sektor: json['sektor'] as String,
        adres: json['adres'] as String,
        telefon: json['telefon'] as String?,
        eposta: json['eposta'] as String?,
        webAdres: json['webAdres'] as String?,
        kurulusTarihi: json['kurulusTarihi'] == null
            ? null
            : DateTime.parse(json['kurulusTarihi'] as String),
        personelSayisi: json['personelSayisi'] as int?,
        guncellemeTarihi: DateTime.parse(json['guncellemeTarihi'] as String),
      );
}
