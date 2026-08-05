export type DestekTalebiDurumu = 'beklemede' | 'yanitlandi' | 'kapali';

export interface DestekTalebiOlusturRequest {
  baslik: string;
  aciklama: string;
}

export interface DestekTalebiResponse {
  id: string;
  baslik: string;
  aciklama: string;
  durum: DestekTalebiDurumu;
  olusturmaTarihi: string;
}
