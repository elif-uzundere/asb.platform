export type AcilDurumTuru = 'yangin' | 'kaza' | 'saglik' | 'diger';

export type AcilDurumBildirimDurumu = 'yeni' | 'inceleniyor' | 'kapatildi';

export interface AcilDurumBildirimiResponse {
  id: string;
  tur: AcilDurumTuru;
  aciklama: string | null;
  durum: AcilDurumBildirimDurumu;
  olusturmaTarihi: string;
}

/** `POST /acil-durum/bildirimler` — konum BİLEREK yok (harita modülü kapsam dışı). */
export interface AcilDurumBildirimiOlusturRequest {
  tur: AcilDurumTuru;
  aciklama: string;
}
