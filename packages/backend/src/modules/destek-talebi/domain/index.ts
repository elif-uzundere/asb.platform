import type { DestekTalebiDurumu } from '@asb/shared-types';

export interface DestekTalebiData {
  id: string;
  baslik: string;
  aciklama: string;
  durum: DestekTalebiDurumu;
  olusturmaTarihi: Date;
}

export interface DestekTalebiOlusturmaVerisi {
  baslik: string;
  aciklama: string;
  kullaniciId: string;
}

export abstract class DestekTalebiRepository {
  abstract olustur(veri: DestekTalebiOlusturmaVerisi): Promise<DestekTalebiData>;

  /** Sadece kendi taleplerini görmeli — başka kullanıcının talebi asla dönmez. */
  abstract kullaniciyaGoreListele(kullaniciId: string): Promise<DestekTalebiData[]>;
}
