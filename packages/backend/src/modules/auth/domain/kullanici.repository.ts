import type { KullaniciRolu } from '@asb/shared-types';
import { Kullanici } from './kullanici.entity';

export interface KullaniciRepository {
  emailIleBul(email: string): Promise<Kullanici | null>;
  idIleBul(id: string): Promise<Kullanici | null>;
  kaydet(kullanici: Kullanici): Promise<Kullanici>;
  sifreGuncelle(id: string, yeniSifreHash: string): Promise<void>;
  epostaGuncelle(id: string, yeniEposta: string): Promise<void>;
  profilGuncelle(
    id: string,
    veri: { ad: string; soyad: string; telefon: string | null },
  ): Promise<Kullanici>;

  /** Bir role sahip tüm kullanıcılar — Acil Durum bildirimlerini ilgili ekibe yönlendirmek için. */
  rolIleListele(rol: KullaniciRolu): Promise<Kullanici[]>;

  /**
   * Bir Cookzone işletmesine bağlı tüm cookzone_yetkilisi kullanıcıları —
   * `rolIleListele('cookzone_yetkilisi')`'den FARKLI: birden fazla işletme
   * olduğunda sadece o işletmeye bağlı olanlara bildirim gitmesi için.
   */
  cookzoneIsletmesineGoreListele(isletmeId: string): Promise<Kullanici[]>;
}

export interface SifreHashPort {
  hashle(duzMetin: string): Promise<string>;
  dogrula(duzMetin: string, hash: string): Promise<boolean>;
}