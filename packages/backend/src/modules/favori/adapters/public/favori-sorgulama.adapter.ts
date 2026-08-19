import { Inject, Injectable } from '@nestjs/common';
import type { FavoriHedefTuru } from '@asb/shared-types';
import type { FavoriRepository } from '../../domain';
import { FAVORI_REPOSITORY } from '../../favori.tokens';
import { FavoriSorgulamaPort } from './favori-sorgulama.port';

@Injectable()
export class FavoriSorgulamaAdapter implements FavoriSorgulamaPort {
  constructor(@Inject(FAVORI_REPOSITORY) private readonly favoriRepo: FavoriRepository) {}

  async sayiGetir(hedefTuru: FavoriHedefTuru, hedefId: string): Promise<number> {
    return this.favoriRepo.sayiGetir(hedefTuru, hedefId);
  }
}
