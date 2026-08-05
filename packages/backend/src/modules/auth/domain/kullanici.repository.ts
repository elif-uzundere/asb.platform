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
}

export interface SifreHashPort {
  hashle(duzMetin: string): Promise<string>;
  dogrula(duzMetin: string, hash: string): Promise<boolean>;
}