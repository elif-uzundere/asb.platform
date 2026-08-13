import { Injectable } from '@nestjs/common';
import type { IsBasvurusu as IsBasvurusuKaydi } from '@prisma/client';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import { IsBasvurusu, IsBasvurusuRepository } from '../../domain';

@Injectable()
export class PrismaIsBasvurusuRepository implements IsBasvurusuRepository {
  constructor(private readonly prisma: PrismaService) {}

  async olustur(basvuru: IsBasvurusu): Promise<IsBasvurusu> {
    const kayit = await this.prisma.isBasvurusu.create({
      data: {
        id: basvuru.id,
        isIlaniId: basvuru.isIlaniId,
        kullaniciId: basvuru.kullaniciId,
        basvuruTarihi: basvuru.basvuruTarihi,
        durum: basvuru.durum,
        cvUrl: basvuru.cvUrl,
      },
    });
    return this.entiteyeCevir(kayit);
  }

  async ilanaGoreListele(isIlaniId: string): Promise<IsBasvurusu[]> {
    const kayitlar = await this.prisma.isBasvurusu.findMany({
      where: { isIlaniId },
      orderBy: { basvuruTarihi: 'desc' },
    });
    return kayitlar.map((kayit) => this.entiteyeCevir(kayit));
  }

  async kullaniciVeIlanaGoreBul(kullaniciId: string, isIlaniId: string): Promise<IsBasvurusu | null> {
    const kayit = await this.prisma.isBasvurusu.findFirst({
      where: { kullaniciId, isIlaniId },
    });
    return kayit ? this.entiteyeCevir(kayit) : null;
  }

  async kullaniciyaGoreListele(kullaniciId: string): Promise<IsBasvurusu[]> {
    const kayitlar = await this.prisma.isBasvurusu.findMany({
      where: { kullaniciId },
      orderBy: { basvuruTarihi: 'desc' },
    });
    return kayitlar.map((kayit) => this.entiteyeCevir(kayit));
  }

  async idIleBul(id: string): Promise<IsBasvurusu | null> {
    const kayit = await this.prisma.isBasvurusu.findUnique({ where: { id } });
    return kayit ? this.entiteyeCevir(kayit) : null;
  }

  async durumGuncelle(id: string, durum: IsBasvurusu['durum']): Promise<IsBasvurusu> {
    const kayit = await this.prisma.isBasvurusu.update({
      where: { id },
      data: { durum },
    });
    return this.entiteyeCevir(kayit);
  }

  private entiteyeCevir(kayit: IsBasvurusuKaydi): IsBasvurusu {
    return new IsBasvurusu(
      kayit.id,
      kayit.isIlaniId,
      kayit.kullaniciId,
      kayit.basvuruTarihi,
      kayit.durum,
      kayit.cvUrl,
    );
  }
}
