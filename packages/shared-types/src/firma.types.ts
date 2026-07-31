export interface FirmaResponse {
  id: string;
  ad: string;
  logoUrl: string | null;
  sektor: string;
  adres: string;
  telefon: string | null;
  eposta: string | null;
  webAdres: string | null;
  kurulusTarihi: string | null;
  personelSayisi: number | null;
  guncellemeTarihi: string;
}

export interface FirmaListeRequest {
  arama?: string;
  sektor?: string;
}

/**
 * Admin yeni firma tanımlarken gönderilen gövde.
 * `onayDurumu` BURADA YOK — BR-1 gereği yeni kayıt her zaman `beklemede`
 * başlar, bu istemcinin karar verebileceği bir şey değil (domain kuralı).
 */
export interface FirmaOlusturRequest {
  ad: string;
  sektor: string;
  adres: string;
  logoUrl?: string;
  telefon?: string;
  eposta?: string;
  webAdres?: string;
  /** ISO 8601 tarih string'i (örn. "2014-01-01") — JSON'da Date tipi yok. */
  kurulusTarihi?: string;
  personelSayisi?: number;
}

/**
 * Admin'in onay kuyruğunda gördüğü firma.
 * `FirmaResponse`'tan farkı: `onayDurumu` var — admin neyi onayladığını /
 * neyin reddedildiğini görmek zorunda. Herkese açık listede bu alan
 * bilinçli olarak yok (iç durum dışarıya sızmaz).
 */
export interface FirmaOnayKuyrugu extends FirmaResponse {
  onayDurumu: FirmaOnayDurumu;
}

export type FirmaOnayDurumu = 'beklemede' | 'onaylandi' | 'reddedildi';
