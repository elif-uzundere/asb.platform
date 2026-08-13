import { Injectable } from '@nestjs/common';
import type { CookzoneIsletme as IsletmeKaydi, CookzoneMenuOgesi as MenuKaydi } from '@prisma/client';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import { CookzoneIsletme, CookzoneIsletmeRepository, CookzoneMenuOgesi } from '../../domain';

@Injectable()
export class PrismaCookzoneIsletmeRepository implements CookzoneIsletmeRepository {
  constructor(private readonly prisma: PrismaService) {}

  async idIleBul(id: string): Promise<CookzoneIsletme | null> {
    const kayit = await this.prisma.cookzoneIsletme.findUnique({ where: { id } });
    return kayit ? this.isletmeyeCevir(kayit) : null;
  }

  async tumunuListele(): Promise<CookzoneIsletme[]> {
    const kayitlar = await this.prisma.cookzoneIsletme.findMany({ orderBy: { ad: 'asc' } });
    return kayitlar.map((kayit) => this.isletmeyeCevir(kayit));
  }

  async menuOgeleriGetir(isletmeId: string): Promise<CookzoneMenuOgesi[]> {
    const kayitlar = await this.prisma.cookzoneMenuOgesi.findMany({
      where: { isletmeId, aktif: true },
      orderBy: [{ kategori: 'asc' }, { ad: 'asc' }],
    });
    return kayitlar.map((kayit) => this.menuOgesineCevir(kayit));
  }

  async menuOgesiIdIleBul(id: string): Promise<CookzoneMenuOgesi | null> {
    const kayit = await this.prisma.cookzoneMenuOgesi.findUnique({ where: { id } });
    return kayit ? this.menuOgesineCevir(kayit) : null;
  }

  private isletmeyeCevir(kayit: IsletmeKaydi): CookzoneIsletme {
    return new CookzoneIsletme(kayit.id, kayit.ad, kayit.bolgeNoktasiId);
  }

  private menuOgesineCevir(kayit: MenuKaydi): CookzoneMenuOgesi {
    return new CookzoneMenuOgesi(
      kayit.id,
      kayit.isletmeId,
      kayit.ad,
      kayit.aciklama,
      Number(kayit.fiyat),
      kayit.kategori,
      kayit.aktif,
    );
  }
}
