import { CookzoneIsletme, CookzoneMenuOgesi } from './cookzone-isletme.entity';

export interface CookzoneIsletmeRepository {
  idIleBul(id: string): Promise<CookzoneIsletme | null>;

  /** Katalog modeli — herkese açık, işletmelerin tamamı (bölgede kaç yemek noktası var). */
  tumunuListele(): Promise<CookzoneIsletme[]>;

  /** Sadece `aktif = true` olan öğeler — pasife çekilmiş bir menü öğesi müşteriye görünmez. */
  menuOgeleriGetir(isletmeId: string): Promise<CookzoneMenuOgesi[]>;

  menuOgesiIdIleBul(id: string): Promise<CookzoneMenuOgesi | null>;
}
