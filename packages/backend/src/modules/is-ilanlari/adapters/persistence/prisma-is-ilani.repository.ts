import { Injectable } from '@nestjs/common';
import type { IsIlani as IsIlaniKaydi } from '@prisma/client';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import { IsIlani, IsIlaniRepository } from '../../domain';
import { IsIlaniListeRequest } from '@asb/shared-types';

@Injectable()
export class PrismaIsIlaniRepository implements IsIlaniRepository {
  constructor(private readonly prisma: PrismaService) {}

  async listele(filtre: IsIlaniListeRequest): Promise<IsIlani[]> {
    const kayitlar = await this.prisma.isIlani.findMany({
      where: {
        durum: 'aktif',
        firmaId: filtre.firmaId ?? undefined,
        konum: filtre.konum ? { contains: filtre.konum, mode: 'insensitive' } : undefined,
      },
      orderBy: { yayinTarihi: 'desc' },
    });
    return kayitlar.map((kayit) => this.entiteyeCevir(kayit));
  }

  async idIleBul(id: string): Promise<IsIlani | null> {
    const kayit = await this.prisma.isIlani.findUnique({ where: { id } });
    return kayit ? this.entiteyeCevir(kayit) : null;
  }

  async olustur(ilan: IsIlani): Promise<IsIlani> {
    const kayit = await this.prisma.isIlani.create({
      data: {
        id: ilan.id,
        firmaId: ilan.firmaId,
        olusturanKullaniciId: ilan.olusturanKullaniciId,
        baslik: ilan.baslik,
        aciklama: ilan.aciklama,
        konum: ilan.konum,
        yayinTarihi: ilan.yayinTarihi,
        durum: ilan.durum,
      },
    });
    return this.entiteyeCevir(kayit);
  }

  async durumGuncelle(id: string, durum: IsIlani['durum']): Promise<IsIlani> {
    const kayit = await this.prisma.isIlani.update({
      where: { id },
      data: { durum },
    });
    return this.entiteyeCevir(kayit);
  }

  private entiteyeCevir(kayit: IsIlaniKaydi): IsIlani {
    return new IsIlani(
      kayit.id,
      kayit.firmaId,
      kayit.olusturanKullaniciId,
      kayit.baslik,
      kayit.aciklama,
      kayit.konum,
      kayit.yayinTarihi,
      kayit.durum,
    );
  }
}
