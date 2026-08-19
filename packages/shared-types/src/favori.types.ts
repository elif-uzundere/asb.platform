export type FavoriHedefTuru = 'ikinci_el' | 'firma' | 'is_ilani';

/** `POST /favoriler` — toggle: zaten favorideyse kaldırır, değilse ekler. */
export interface FavoriDurumDegistirRequest {
  hedefTuru: FavoriHedefTuru;
  hedefId: string;
}

export interface FavoriDurumDegistirResponse {
  favoride: boolean;
}

/** `GET /favoriler?tur=...` — kullanıcının o türdeki favorilediği hedeflerin id listesi. */
export type FavorilerimResponse = string[];
