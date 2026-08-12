import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../shared/infrastructure/prisma.service';

import {
  Palet,
  PaletTesisiBilgisi,
  PaletTesisiRepository,
} from '../domain';

@Injectable()
export class PrismaPaletTesisiRepository
  extends PaletTesisiRepository {
  constructor(
    private readonly prismaService:
      PrismaService,
  ) {
    super();
  }

  async tesisBilgisiGetir():
    Promise<PaletTesisiBilgisi | null> {
    const bilgi =
      await this.prismaService
        .paletTesisiBilgisi
        .findFirst();

    if (!bilgi) {
      return null;
    }

    return {
      id: bilgi.id,
      telefon: bilgi.telefon,
      eposta: bilgi.eposta,
      adres: bilgi.adres,
      aciklama: bilgi.aciklama,
      calismaSaatleri:
        bilgi.calismaSaatleri,
    };
  }

  async paletleriGetir():
    Promise<Palet[]> {
    const paletler =
      await this.prismaService.palet.findMany({
        where: {
          aktif: true,
        },
        orderBy: {
          sira: 'asc',
        },
      });

    return paletler.map(
      (palet) => ({
        id: palet.id,
        ad: palet.ad,
        aciklama: palet.aciklama,
        olcu: palet.olcu,
        gorselUrl: palet.gorselUrl,
        sira: palet.sira,
      }),
    );
  }
}