import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';
import type { Palet as PaletKaydi } from '@prisma/client';

import { PrismaService } from '../../../shared/infrastructure/prisma.service';

import {
  Palet,
  PaletGuncelleVerisi,
  PaletOlusturVerisi,
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

    return paletler.map((palet) => this.entiteyeCevir(palet));
  }

  async tumPaletleriGetir(): Promise<Palet[]> {
    const paletler = await this.prismaService.palet.findMany({
      orderBy: { sira: 'asc' },
    });
    return paletler.map((palet) => this.entiteyeCevir(palet));
  }

  async paletIdIleBul(id: string): Promise<Palet | null> {
    const palet = await this.prismaService.palet.findUnique({ where: { id } });
    return palet ? this.entiteyeCevir(palet) : null;
  }

  async paletOlustur(veri: PaletOlusturVerisi): Promise<Palet> {
    const enSonSira = await this.prismaService.palet.aggregate({ _max: { sira: true } });
    const palet = await this.prismaService.palet.create({
      data: {
        id: randomUUID(),
        ad: veri.ad,
        aciklama: veri.aciklama,
        olcu: veri.olcu,
        gorselUrl: veri.gorselUrl,
        sira: (enSonSira._max.sira ?? 0) + 1,
      },
    });
    return this.entiteyeCevir(palet);
  }

  async paletGuncelle(id: string, veri: PaletGuncelleVerisi): Promise<Palet> {
    const palet = await this.prismaService.palet.update({
      where: { id },
      data: {
        ad: veri.ad,
        aciklama: veri.aciklama,
        olcu: veri.olcu,
        gorselUrl: veri.gorselUrl,
      },
    });
    return this.entiteyeCevir(palet);
  }

  private entiteyeCevir(palet: PaletKaydi): Palet {
    return {
      id: palet.id,
      ad: palet.ad,
      aciklama: palet.aciklama,
      olcu: palet.olcu,
      gorselUrl: palet.gorselUrl,
      aktif: palet.aktif,
      sira: palet.sira,
    };
  }
}