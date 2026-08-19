import type { FavoriHedefTuru } from '@asb/shared-types';
import { FavoriRepository } from '../domain';

/**
 * Saf TypeScript — NestJS decorator'ı YOK (mimari kural 2), destek-talebi
 * service.ts ile aynı desen.
 */
export class FavoriService {
  constructor(private readonly favoriRepository: FavoriRepository) {}

  /** Kalp butonuna her basışta çağrılır — zaten favorideyse kaldırır, değilse ekler. */
  async durumDegistir(
    kullaniciId: string,
    hedefTuru: FavoriHedefTuru,
    hedefId: string,
  ): Promise<{ favoride: boolean }> {
    const favoride = await this.favoriRepository.varMi(kullaniciId, hedefTuru, hedefId);
    if (favoride) {
      await this.favoriRepository.kaldir(kullaniciId, hedefTuru, hedefId);
      return { favoride: false };
    }
    await this.favoriRepository.ekle(kullaniciId, hedefTuru, hedefId);
    return { favoride: true };
  }

  async favorilerimGetir(kullaniciId: string, hedefTuru: FavoriHedefTuru): Promise<string[]> {
    return this.favoriRepository.kullanicininFavorileri(kullaniciId, hedefTuru);
  }

  async sayiGetir(hedefTuru: FavoriHedefTuru, hedefId: string): Promise<number> {
    return this.favoriRepository.sayiGetir(hedefTuru, hedefId);
  }
}
