import { Injectable } from '@nestjs/common';

import {
  Palet,
  PaletBulunamadiException,
  PaletGuncelleVerisi,
  PaletOlusturVerisi,
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

  /** Palet Tesisi yetkilisinin yönetim ekranı — pasif olanlar dahil. */
  async tumPaletleriGetir(): Promise<Palet[]> {
    return this.paletTesisiRepository.tumPaletleriGetir();
  }

  async paletOlustur(veri: PaletOlusturVerisi): Promise<Palet> {
    return this.paletTesisiRepository.paletOlustur(veri);
  }

  async paletGuncelle(id: string, veri: PaletGuncelleVerisi): Promise<Palet> {
    const mevcut = await this.paletTesisiRepository.paletIdIleBul(id);
    if (!mevcut) {
      throw new PaletBulunamadiException();
    }
    return this.paletTesisiRepository.paletGuncelle(id, veri);
  }
}