import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { CookzoneIsletme as IsletmeKaydi, CookzoneMenuOgesi as MenuKaydi } from '@prisma/client';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import {
  CookzoneIsletme,
  CookzoneIsletmeRepository,
  CookzoneMenuOgesi,
  CookzoneMenuOgesiGuncellemeVerisi,
  CookzoneMenuOgesiOlusturmaVerisi,
} from '../../domain';

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

  async menuOgeleriTumunuGetir(isletmeId: string): Promise<CookzoneMenuOgesi[]> {
    const kayitlar = await this.prisma.cookzoneMenuOgesi.findMany({
      where: { isletmeId },
      orderBy: [{ kategori: 'asc' }, { ad: 'asc' }],
    });
    return kayitlar.map((kayit) => this.menuOgesineCevir(kayit));
  }

  async menuOgesiIdIleBul(id: string): Promise<CookzoneMenuOgesi | null> {
    const kayit = await this.prisma.cookzoneMenuOgesi.findUnique({ where: { id } });
    return kayit ? this.menuOgesineCevir(kayit) : null;
  }

  async menuOgesiOlustur(veri: CookzoneMenuOgesiOlusturmaVerisi): Promise<CookzoneMenuOgesi> {
    const kayit = await this.prisma.cookzoneMenuOgesi.create({
      data: {
        isletmeId: veri.isletmeId,
        ad: veri.ad,
        aciklama: veri.aciklama,
        fiyat: new Prisma.Decimal(veri.fiyat),
        kategori: veri.kategori,
        gorselUrl: veri.gorselUrl,
      },
    });
    return this.menuOgesineCevir(kayit);
  }

  async menuOgesiGuncelle(id: string, veri: CookzoneMenuOgesiGuncellemeVerisi): Promise<CookzoneMenuOgesi> {
    const kayit = await this.prisma.cookzoneMenuOgesi.update({
      where: { id },
      data: {
        ...(veri.ad !== undefined ? { ad: veri.ad } : {}),
        ...(veri.aciklama !== undefined ? { aciklama: veri.aciklama } : {}),
        ...(veri.fiyat !== undefined ? { fiyat: new Prisma.Decimal(veri.fiyat) } : {}),
        ...(veri.kategori !== undefined ? { kategori: veri.kategori } : {}),
        ...(veri.gorselUrl !== undefined ? { gorselUrl: veri.gorselUrl } : {}),
        ...(veri.aktif !== undefined ? { aktif: veri.aktif } : {}),
      },
    });
    return this.menuOgesineCevir(kayit);
  }

  async menuOgesiSil(id: string): Promise<void> {
    await this.prisma.cookzoneMenuOgesi.update({ where: { id }, data: { aktif: false } });
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
      kayit.gorselUrl,
    );
  }
}
