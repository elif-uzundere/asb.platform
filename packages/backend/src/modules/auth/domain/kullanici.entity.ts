import { Email } from './email.vo';

export type KullaniciRolu = 'ziyaretci' | 'firma_calisani' | 'firma_yetkilisi' | 'admin';

export class Kullanici {
  constructor(
    public readonly id: string,
    public readonly email: Email,
    public readonly sifreHash: string,
    public readonly ad: string,
    public readonly soyad: string,
    public readonly rol: KullaniciRolu,
    public readonly firmaId: string | null,
    public readonly epostaDogrulandi: boolean,
  ) {}
}