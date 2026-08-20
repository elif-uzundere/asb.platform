export type AcilDurumTuru = 'yangin' | 'kaza' | 'saglik' | 'kantar' | 'gumruk' | 'diger';

export type AcilDurumBildirimDurumu = 'yeni' | 'inceleniyor' | 'kapatildi';

export interface AcilDurumBildirimi {
  id: string;
  kullaniciId: string;
  tur: AcilDurumTuru;
  aciklama: string | null;
  durum: AcilDurumBildirimDurumu;
  olusturmaTarihi: Date;
}

/** `POST /acil-durum/bildirimler` gövdesi. Konum bilerek yok, harita/navigasyon
 * modülü bu kapsamın dışında bırakıldı. */
export interface AcilDurumBildirimiOlusturVerisi {
  kullaniciId: string;
  tur: AcilDurumTuru;
  aciklama: string | null;
}
