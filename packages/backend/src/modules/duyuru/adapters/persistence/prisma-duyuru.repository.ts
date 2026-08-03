import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import { DuyuruData, DuyuruOlusturmaVerisi, DuyuruRepository } from '../../domain';

@Injectable()
export class PrismaDuyuruRepository extends DuyuruRepository {
  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async tumDuyurulariGetir(): Promise<DuyuruData[]> {
    return this.prisma.duyuru.findMany({
      orderBy: {
        yayinTarihi: 'desc',
      },
      select: {
        id: true,
        baslik: true,
        icerik: true,
        kategori: true,
        yayinTarihi: true,
      },
    });
  }

  async duyuruGetir(id: string): Promise<DuyuruData | null> {
    return this.prisma.duyuru.findUnique({
      where: {
        id,
      },
      select: {
        id: true,
        baslik: true,
        icerik: true,
        kategori: true,
        yayinTarihi: true,
      },
    });
  }

  async duyuruOlustur(veri: DuyuruOlusturmaVerisi): Promise<DuyuruData> {
    return this.prisma.duyuru.create({
      data: {
        baslik: veri.baslik,
        icerik: veri.icerik,
        ...(veri.kategori !== undefined ? { kategori: veri.kategori } : {}),
        ...(veri.yayinTarihi ? { yayinTarihi: veri.yayinTarihi } : {}),
        olusturanKullaniciId: veri.olusturanKullaniciId,
      },
      select: {
        id: true,
        baslik: true,
        icerik: true,
        kategori: true,
        yayinTarihi: true,
      },
    });
  }
}