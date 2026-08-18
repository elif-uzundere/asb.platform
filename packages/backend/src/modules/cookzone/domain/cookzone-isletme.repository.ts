import {
  CookzoneIsletme,
  CookzoneMenuOgesi,
  CookzoneMenuOgesiGuncellemeVerisi,
  CookzoneMenuOgesiOlusturmaVerisi,
} from './cookzone-isletme.entity';

export interface CookzoneIsletmeRepository {
  idIleBul(id: string): Promise<CookzoneIsletme | null>;

  /** Katalog modeli — herkese açık, işletmelerin tamamı (bölgede kaç yemek noktası var). */
  tumunuListele(): Promise<CookzoneIsletme[]>;

  /** Sadece `aktif = true` olan öğeler — pasife çekilmiş bir menü öğesi müşteriye görünmez. */
  menuOgeleriGetir(isletmeId: string): Promise<CookzoneMenuOgesi[]>;

  /** Pasif dahil TÜMÜ — cookzone_yetkilisi'nin yönetim ekranı için (Palet
   * Tesisi'ndeki `tumPaletleriGetir` ile aynı gerekçe). */
  menuOgeleriTumunuGetir(isletmeId: string): Promise<CookzoneMenuOgesi[]>;

  menuOgesiIdIleBul(id: string): Promise<CookzoneMenuOgesi | null>;

  menuOgesiOlustur(veri: CookzoneMenuOgesiOlusturmaVerisi): Promise<CookzoneMenuOgesi>;

  menuOgesiGuncelle(id: string, veri: CookzoneMenuOgesiGuncellemeVerisi): Promise<CookzoneMenuOgesi>;

  /** Soft-delete — `aktif = false` yapar. Geçmiş siparişlerin kalemleri bu
   * öğeye FK ile bağlı olduğu için gerçek satır silinmiyor. */
  menuOgesiSil(id: string): Promise<void>;
}
