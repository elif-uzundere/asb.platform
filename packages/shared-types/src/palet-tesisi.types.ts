export interface PaletTesisiBilgisiResponse {
  id: string;
  telefon: string | null;
  eposta: string | null;
  adres: string | null;
  aciklama: string | null;
  calismaSaatleri: string | null;
}

export interface PaletResponse {
  id: string;
  ad: string;
  aciklama: string | null;
  olcu: string | null;
  gorselUrl: string | null;
  aktif: boolean;
  sira: number;
}

/**
 * `POST /palet-tesisi/paletler` — `gorsel` bu DTO'da YOK, multipart form'un
 * ayrı bir alanı (ayni CookzoneSiparisOlusturRequest'in dosyaları taşımaması
 * gibi, dosya JSON gövdesinin parçası olamaz).
 */
export interface PaletOlusturRequest {
  ad: string;
  aciklama?: string;
  olcu?: string;
}

/** `PUT /palet-tesisi/paletler/:id` — tüm alanlar opsiyonel, kısmi güncelleme. */
export interface PaletGuncelleRequest {
  ad?: string;
  aciklama?: string;
  olcu?: string;
}
