import { Inject, Injectable } from '@nestjs/common';
import type { BolgeNoktasiRepository } from '../../domain';
import { BOLGE_NOKTASI_REPOSITORY } from '../../harita.tokens';
import { BolgeNoktasiSorgulamaPort } from './bolge-noktasi-sorgulama.port';

@Injectable()
export class BolgeNoktasiSorgulamaAdapter implements BolgeNoktasiSorgulamaPort {
  constructor(@Inject(BOLGE_NOKTASI_REPOSITORY) private readonly repo: BolgeNoktasiRepository) {}

  async adiGetir(id: string): Promise<string | null> {
    return this.repo.adiGetir(id);
  }
}
