export type CookzoneSiparisDurumu = 'beklemede' | 'alindi' | 'hazirlaniyor' | 'hazir' | 'teslim_edildi';

export type CihazPlatformu = 'android' | 'ios' | 'web';

export interface CookzoneMenuOgesiResponse {
  id: string;
  ad: string;
  aciklama: string | null;
  fiyat: number;
  kategori: string;
}

/** Menü ekranı — bir işletmenin bilgisi + aktif menü öğeleri (kategori bazlı gruplama Flutter tarafında). */
export interface CookzoneIsletmeResponse {
  id: string;
  ad: string;
  bolgeNoktasiAdi: string;
  menuOgeleri: CookzoneMenuOgesiResponse[];
}

export interface CookzoneSiparisKalemiRequest {
  menuOgesiId: string;
  adet: number;
}

/**
 * `alinmaSaati` — teslimat YOK, randevulu hazır-olma modeli: müşterinin
 * "şu saatte gelip alacağım" dediği zaman. ISO 8601 string (JSON'da Date yok).
 */
export interface CookzoneSiparisOlusturRequest {
  isletmeId: string;
  alinmaSaati: string;
  kalemler: CookzoneSiparisKalemiRequest[];
}

export interface CookzoneSiparisKalemiResponse {
  id: string;
  menuOgesiAdi: string;
  adet: number;
  birimFiyat: number;
}

/** Müşterinin kendi siparişini görme görünümü — "Siparişlerim". */
export interface CookzoneSiparisResponse {
  id: string;
  isletmeId: string;
  isletmeAdi: string;
  durum: CookzoneSiparisDurumu;
  toplamTutar: number;
  alinmaSaati: string;
  olusturmaTarihi: string;
  kalemler: CookzoneSiparisKalemiResponse[];
}

/**
 * `cookzone_yetkilisi`'nin sipariş kuyruğunda görme görünümü —
 * `CookzoneSiparisResponse`'tan farkı: o "ben nereye sipariş verdim" (işletme
 * adı taşır), bu "bana kim sipariş verdi" (müşteri adı taşır). İş İlanları
 * modülündeki `BasvurumResponse`/`IsBasvurusuResponse` ayrımıyla aynı gerekçe.
 */
export interface CookzoneSiparisYonetimResponse {
  id: string;
  kullaniciAdSoyad: string;
  durum: CookzoneSiparisDurumu;
  toplamTutar: number;
  alinmaSaati: string;
  olusturmaTarihi: string;
  kalemler: CookzoneSiparisKalemiResponse[];
}

export interface CihazTokeniKaydetRequest {
  token: string;
  platform: CihazPlatformu;
}
