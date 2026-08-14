export type AcilDurumTuru = 'yangin' | 'kaza' | 'saglik' | 'diger';

export type AcilDurumBildirimDurumu = 'yeni' | 'inceleniyor' | 'kapatildi';

export interface AcilDurumBildirimi {
  id: string;
  kullaniciId: string;
  tur: AcilDurumTuru;
  aciklama: string | null;
  durum: AcilDurumBildirimDurumu;
  olusturmaTarihi: Date;
}

/** `POST /acil-durum/bildirimler` gövdesi — konum BİLEREK yok (13.08.2026,
 * harita/navigasyon modülü bu kapsamın dışında bırakıldı). */
export interface AcilDurumBildirimiOlusturVerisi {
  kullaniciId: string;
  tur: AcilDurumTuru;
  aciklama: string | null;
}
