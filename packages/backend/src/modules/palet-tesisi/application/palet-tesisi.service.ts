import { Injectable } from '@nestjs/common';

import {
  Palet,
  PaletTesisiBilgisi,
  PaletTesisiRepository,
} from '../domain';

@Injectable()
export class PaletTesisiService {
  constructor(
    private readonly paletTesisiRepository:
      PaletTesisiRepository,
  ) {}

  async tesisBilgisiGetir():
    Promise<PaletTesisiBilgisi | null> {
    return this.paletTesisiRepository
      .tesisBilgisiGetir();
  }

  async paletleriGetir():
    Promise<Palet[]> {
    return this.paletTesisiRepository
      .paletleriGetir();
  }
}