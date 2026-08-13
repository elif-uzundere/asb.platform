export interface Palet {
  id: string;
  ad: string;
  aciklama: string | null;
  olcu: string | null;
  gorselUrl: string | null;
  aktif: boolean;
  sira: number;
}

/** `PaletTesisiController.paletOlustur` — `gorselUrl` yükleme başarılıysa doldurulur. */
export interface PaletOlusturVerisi {
  ad: string;
  aciklama: string | null;
  olcu: string | null;
  gorselUrl: string | null;
}

/**
 * Kısmi güncelleme — sadece gönderilen alanlar değişir. `undefined` "bu alana
 * dokunma" demek, `null` (gorselUrl için) "görseli kaldır" demek — bu ayrım
 * yüzünden `Partial<Palet>` yerine ayrı bir tip.
 */
export interface PaletGuncelleVerisi {
  ad?: string;
  aciklama?: string | null;
  olcu?: string | null;
  gorselUrl?: string | null;
}