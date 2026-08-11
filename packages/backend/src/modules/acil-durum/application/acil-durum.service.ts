import { Injectable } from '@nestjs/common';

import {
  AcilDurumBilgisi,
  AcilDurumRepository,
  ToplanmaAlani,
} from '../domain';

@Injectable()
export class AcilDurumService {
  constructor(
    private readonly acilDurumRepository: AcilDurumRepository,
  ) {}

  async bilgileriGetir(): Promise<AcilDurumBilgisi[]> {
    return this.acilDurumRepository.bilgileriGetir();
  }

  async toplanmaAlanlariniGetir(): Promise<ToplanmaAlani[]> {
    return this.acilDurumRepository.toplanmaAlanlariniGetir();
  }
}