import { Firma } from './firma.entity';
import { FirmaListeRequest } from '@asb/shared-types';

export interface FirmaRepository {
  /**
   * Herkese açık liste. Görünürlük süzgeci (onaylı + aktif) BURADA, yani
   * SQL'de uygulanır — onaylanmamış kayıtları uygulamaya taşıyıp bellekte
   * ayıklamak gereksiz iş ve firma sayısı artınca ölçeklenmiyor.
   */
  listele(filtre: FirmaListeRequest): Promise<Firma[]>;

  /**
   * Görünürlük süzgeci UYGULAMAZ — bilinçli. Admin, onay bekleyen bir firmayı
   * onaylamak için önce okumak zorunda. Herkese açık detay yolundaki süzgeci
   * `FirmaService.detay()` uyguluyor.
   */
  idIleBul(id: string): Promise<Firma | null>;

  /** Sektör çiplerini beslemek için — sadece görünür firmaların sektörleri. */
  sektorleriGetir(): Promise<string[]>;

  /** Onay kuyruğu (admin): henüz onaylanmamış kayıtlar. */
  onayBekleyenleriGetir(): Promise<Firma[]>;

  olustur(firma: Firma): Promise<Firma>;

  onayDurumuGuncelle(id: string, durum: Firma['onayDurumu']): Promise<Firma>;
}
