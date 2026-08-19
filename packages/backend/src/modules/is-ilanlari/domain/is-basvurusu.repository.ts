import { IsBasvurusu } from './is-basvurusu.entity';

export interface IsBasvurusuRepository {
  olustur(basvuru: IsBasvurusu): Promise<IsBasvurusu>;

  /** Firma yetkilisinin bir ilana gelen tüm başvuruları görmesi için. */
  ilanaGoreListele(isIlaniId: string): Promise<IsBasvurusu[]>;

  /** Sadece SAYI — kim başvurdu bilgisini taşımaz, sahiplik kontrolü
   * gerektirmeden (herkese açık ilan listesinde de gösterilebilir). */
  ilanaGoreSayiGetir(isIlaniId: string): Promise<number>;

  /** Mükerrer başvuru kontrolü — aynı kullanıcı aynı ilana ikinci kez başvuramaz. */
  kullaniciVeIlanaGoreBul(kullaniciId: string, isIlaniId: string): Promise<IsBasvurusu | null>;

  /** Bir kullanıcının kendi yaptığı tüm başvuruları görmesi için (Profil → Başvurularım). */
  kullaniciyaGoreListele(kullaniciId: string): Promise<IsBasvurusu[]>;

  idIleBul(id: string): Promise<IsBasvurusu | null>;

  /** Firma yetkilisinin başvuruyu incele/reddet/kabul et kararı. */
  durumGuncelle(id: string, durum: IsBasvurusu['durum']): Promise<IsBasvurusu>;
}
