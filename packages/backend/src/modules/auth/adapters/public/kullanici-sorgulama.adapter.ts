import { Inject, Injectable } from '@nestjs/common';
import type { KullaniciRolu } from '@asb/shared-types';
import type { KullaniciRepository } from '../../domain';
import { KULLANICI_REPOSITORY } from '../../auth.tokens';
import { KullaniciSorgulamaPort } from './kullanici-sorgulama.port';

@Injectable()
export class KullaniciSorgulamaAdapter implements KullaniciSorgulamaPort {
  constructor(@Inject(KULLANICI_REPOSITORY) private readonly kullaniciRepo: KullaniciRepository) {}

  async adSoyadGetir(kullaniciId: string): Promise<string | null> {
    const kullanici = await this.kullaniciRepo.idIleBul(kullaniciId);
    return kullanici ? `${kullanici.ad} ${kullanici.soyad}` : null;
  }

  async rolIleKullanicilariGetir(rol: KullaniciRolu): Promise<{ id: string; adSoyad: string }[]> {
    const kullanicilar = await this.kullaniciRepo.rolIleListele(rol);
    return kullanicilar.map((kullanici) => ({ id: kullanici.id, adSoyad: `${kullanici.ad} ${kullanici.soyad}` }));
  }

  async cookzoneIsletmesineGoreKullanicilariGetir(isletmeId: string): Promise<{ id: string; adSoyad: string }[]> {
    const kullanicilar = await this.kullaniciRepo.cookzoneIsletmesineGoreListele(isletmeId);
    return kullanicilar.map((kullanici) => ({ id: kullanici.id, adSoyad: `${kullanici.ad} ${kullanici.soyad}` }));
  }
}
