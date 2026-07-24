import { Kullanici } from './kullanici.entity';

export interface TokenUreticiPort {
  uret(kullanici: Kullanici): Promise<string>;
}