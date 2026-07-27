import { Kullanici } from './kullanici.entity';

export interface TokenUreticiPort {
  uret(kullanici: Kullanici, uzunSureli?: boolean): Promise<string>;
  sifirlamaTokenUret(kullanici: Kullanici): Promise<string>;
  sifirlamaTokenDogrula(token: string): Promise<string | null>;
}