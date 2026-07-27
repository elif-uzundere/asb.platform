import { Kullanici } from './kullanici.entity';

export interface KullaniciRepository {
  emailIleBul(email: string): Promise<Kullanici | null>;
  idIleBul(id: string): Promise<Kullanici | null>;
  kaydet(kullanici: Kullanici): Promise<Kullanici>;
  sifreGuncelle(id: string, yeniSifreHash: string): Promise<void>;
}

export interface SifreHashPort {
  hashle(duzMetin: string): Promise<string>;
  dogrula(duzMetin: string, hash: string): Promise<boolean>;
}