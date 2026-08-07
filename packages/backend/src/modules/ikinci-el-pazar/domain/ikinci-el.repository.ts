import {
  IkinciElIlani,
  IkinciElIlaniOlusturmaVerisi,
} from './ikinci-el-ilani';

/**
 * İkinci el ilanlarının veritabanı işlemleri için sözleşme.
 *
 * Domain katmanı Prisma kullanıldığını bilmez.
 * Sadece hangi işlemlere ihtiyaç duyduğunu söyler.
 */
export abstract class IkinciElRepository {
  /**
   * Yayında olan aktif ilanları getirir.
   */
  abstract aktifIlanlariGetir(): Promise<IkinciElIlani[]>;

  /**
   * Yeni bir ikinci el ilanı oluşturur.
   */
  abstract ilanOlustur(
    veri: IkinciElIlaniOlusturmaVerisi,
  ): Promise<IkinciElIlani>;
}