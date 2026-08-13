import { IsIlani } from './is-ilani.entity';
import { IsIlaniListeRequest } from '@asb/shared-types';

export interface IsIlaniRepository {
  /** Katalog modeli — herkese açık, süzgeç (konum/firma) SQL'de uygulanır. */
  listele(filtre: IsIlaniListeRequest): Promise<IsIlani[]>;

  idIleBul(id: string): Promise<IsIlani | null>;

  olustur(ilan: IsIlani): Promise<IsIlani>;

  durumGuncelle(id: string, durum: IsIlani['durum']): Promise<IsIlani>;
}
