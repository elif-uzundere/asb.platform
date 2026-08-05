import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import {
  DestekTalebiData,
  DestekTalebiOlusturmaVerisi,
  DestekTalebiRepository,
} from '../../domain';

const SECILEN_ALANLAR = {
  id: true,
  baslik: true,
  aciklama: true,
  durum: true,
  olusturmaTarihi: true,
} as const;

@Injectable()
export class PrismaDestekTalebiRepository extends DestekTalebiRepository {
  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async olustur(veri: DestekTalebiOlusturmaVerisi): Promise<DestekTalebiData> {
    return this.prisma.destekTalebi.create({
      data: {
        baslik: veri.baslik,
        aciklama: veri.aciklama,
        kullaniciId: veri.kullaniciId,
      },
      select: SECILEN_ALANLAR,
    });
  }

  async kullaniciyaGoreListele(kullaniciId: string): Promise<DestekTalebiData[]> {
    return this.prisma.destekTalebi.findMany({
      where: { kullaniciId },
      orderBy: { olusturmaTarihi: 'desc' },
      select: SECILEN_ALANLAR,
    });
  }
}
