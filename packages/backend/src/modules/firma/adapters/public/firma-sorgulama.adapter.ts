import { Inject, Injectable } from '@nestjs/common';
import type { FirmaRepository } from '../../domain';
import { FIRMA_REPOSITORY } from '../../firma.tokens';
import { FirmaSorgulamaPort } from './firma-sorgulama.port';

@Injectable()
export class FirmaSorgulamaAdapter implements FirmaSorgulamaPort {
  constructor(@Inject(FIRMA_REPOSITORY) private readonly firmaRepo: FirmaRepository) {}

  async isOnayli(firmaId: string): Promise<boolean> {
    const firma = await this.firmaRepo.idIleBul(firmaId);
    return firma?.goruntulenebilir() ?? false;
  }

  async adiGetir(firmaId: string): Promise<string | null> {
    const firma = await this.firmaRepo.idIleBul(firmaId);
    return firma?.ad ?? null;
  }
}