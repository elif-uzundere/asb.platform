export type IsIlaniDurumu = 'aktif' | 'kapali';

export type IsBasvurusuDurumu = 'beklemede' | 'incelendi' | 'reddedildi' | 'kabul';

export interface IsIlaniResponse {
  id: string;
  firmaId: string;
  firmaAdi: string;
  baslik: string;
  aciklama: string;
  konum: string | null;
  yayinTarihi: string;
  durum: IsIlaniDurumu;
  /** Kaç kişi favoriledi / kaç başvuru geldi. İş ilanı açan, kaç kişi
   * favori yapmış kaç başvuru gelmiş görebilsin diye. */
  favoriSayisi: number;
  basvuruSayisi: number;
}

export interface IsIlaniListeRequest {
  konum?: string;
  firmaId?: string;
}

/**
 * `firmaId` ve `durum` burada yok. Firma yetkilisinin ilanı yayınladığı
 * firma token'dan (`AktifKullanici.firmaId`) geliyor, `durum` her zaman
 * `aktif` başlıyor. İkisi de FirmaOlusturRequest'teki `onayDurumu` yokluğuyla
 * aynı gerekçeye dayanıyor: istemcinin karar veremeyeceği alanlar DTO'da yer
 * almaz, kural entity'de yaşar.
 */
export interface IsIlaniOlusturRequest {
  baslik: string;
  aciklama: string;
  konum?: string;
}

export interface IsBasvurusuResponse {
  id: string;
  isIlaniId: string;
  kullaniciId: string;
  kullaniciAdSoyad: string;
  basvuruTarihi: string;
  durum: IsBasvurusuDurumu;
  cvUrl: string | null;
}

/**
 * `PUT /is-ilanlari/:id/basvurular/:basvuruId/durum` — firma yetkilisinin
 * bir başvuruyu inceleme/kabul/red kararı. `beklemede` BİLEREK yok, geriye
 * dönüş (kabul edilmiş bir başvuruyu tekrar beklemeye almak) desteklenmiyor.
 */
export interface IsBasvurusuDurumGuncelleRequest {
  durum: Exclude<IsBasvurusuDurumu, 'beklemede'>;
}

/**
 * `GET /is-ilanlari/basvurularim` — `IsBasvurusuResponse`'tan farkı: o,
 * firma yetkilisinin "bu ilana kim başvurdu" görünümü (kullaniciAdSoyad
 * taşır); bu, başvuru sahibinin kendi başvurularını görme görünümü
 * (hangi ilana/firmaya başvurduğunu taşır). İkisi aynı DB satırının farklı
 * taraflardan okunuşu, kasıtlı olarak ayrı tipler.
 */
export interface BasvurumResponse {
  id: string;
  isIlaniId: string;
  isIlaniBasligi: string;
  firmaAdi: string;
  basvuruTarihi: string;
  durum: IsBasvurusuDurumu;
  cvUrl: string | null;
}
