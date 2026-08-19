import type { FavoriHedefTuru } from '@asb/shared-types';

export interface FavoriData {
  id: string;
  kullaniciId: string;
  hedefTuru: FavoriHedefTuru;
  hedefId: string;
  olusturmaTarihi: Date;
}

export abstract class FavoriRepository {
  abstract ekle(kullaniciId: string, hedefTuru: FavoriHedefTuru, hedefId: string): Promise<FavoriData>;

  abstract kaldir(kullaniciId: string, hedefTuru: FavoriHedefTuru, hedefId: string): Promise<void>;

  abstract varMi(kullaniciId: string, hedefTuru: FavoriHedefTuru, hedefId: string): Promise<boolean>;

  /** Kullanıcının o türdeki favorilediği hedeflerin id listesi (Favorilerim ekranı için). */
  abstract kullanicininFavorileri(kullaniciId: string, hedefTuru: FavoriHedefTuru): Promise<string[]>;

  /** Bir hedefi kaç kullanıcı favoriledi — İş İlanı sahibinin görmesi için. */
  abstract sayiGetir(hedefTuru: FavoriHedefTuru, hedefId: string): Promise<number>;
}
