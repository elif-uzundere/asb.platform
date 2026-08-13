import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../../shared/infrastructure/prisma.service';

import {
  AcilDurumBilgisi,
  AcilDurumRepository,
  ToplanmaAlani,
} from '../../domain';

@Injectable()
export class PrismaAcilDurumRepository extends AcilDurumRepository {
  constructor(
    private readonly prismaService: PrismaService,
  ) {
    super();
  }

  async bilgileriGetir(): Promise<AcilDurumBilgisi[]> {
    const bilgiler =
        await this.prismaService.acilDurumBilgisi.findMany();

    return bilgiler.map((bilgi) => ({
      id: bilgi.id,
      tur: bilgi.tur,
      telefon: bilgi.telefon,
      telefon2: bilgi.telefon2,
      eposta: bilgi.eposta,
      adres: bilgi.adres,
      aciklama: bilgi.aciklama,
      calismaSaatleri: bilgi.calismaSaatleri,
    }));
  }

  async toplanmaAlanlariniGetir(): Promise<ToplanmaAlani[]> {
    const alanlar =
        await this.prismaService.toplanmaAlani.findMany({
      where: {
        aktif: true,
      },
      orderBy: {
        sira: 'asc',
      },
    });

    return alanlar.map((alan) => ({
      id: alan.id,
      ad: alan.ad,
      aciklama: alan.aciklama,
      enlem: Number(alan.enlem),
      boylam: Number(alan.boylam),
      sira: alan.sira,
    }));
  }
}