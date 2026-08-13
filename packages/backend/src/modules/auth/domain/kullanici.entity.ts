import type { KullaniciRolu } from '@asb/shared-types';
import { Email } from './email.vo';

// Daha önce burada ayrı tanımlıydı (shared-types'takinden bağımsız kopya) —
// `cookzone_yetkilisi` eklenirken iki yerin senkronsuz kalma riski fark
// edildi (Firma modülündeki `FirmaOnayDurumu` re-export deseniyle aynı
// gerekçe: tek kaynak = shared-types).
export type { KullaniciRolu };

export class Kullanici {
  constructor(
    public readonly id: string,
    public readonly email: Email,
    /** null → şifresiz hesap (Google/Apple gibi sosyal girişle açıldı). */
    public readonly sifreHash: string | null,
    public readonly ad: string,
    public readonly soyad: string,
    public readonly rol: KullaniciRolu,
    public readonly firmaId: string | null,
    public readonly epostaDogrulandi: boolean,
    public readonly telefon: string | null = null,
    /** Sadece rol = cookzone_yetkilisi olan hesaplarda dolu. */
    public readonly cookzoneIsletmeId: string | null = null,
  ) {}
}