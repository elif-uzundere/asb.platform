import { Injectable } from '@nestjs/common';
import type { CookzoneSiparis as SiparisKaydi, CookzoneSiparisDurumu as PrismaDurum } from '@prisma/client';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import {
  CookzoneSiparis,
  CookzoneSiparisDurumu,
  CookzoneSiparisKalemi,
  CookzoneSiparisRepository,
} from '../../domain';

@Injectable()
export class PrismaCookzoneSiparisRepository implements CookzoneSiparisRepository {
  constructor(private readonly prisma: PrismaService) {}

  async olustur(
    siparis: CookzoneSiparis,
    kalemler: { menuOgesiId: string; adet: number }[],
  ): Promise<CookzoneSiparis> {
    const kayit = await this.prisma.cookzoneSiparis.create({
      data: {
        id: siparis.id,
        kullaniciId: siparis.kullaniciId,
        isletmeId: siparis.isletmeId,
        durum: siparis.durum,
        toplamTutar: siparis.toplamTutar,
        alinmaSaati: siparis.alinmaSaati,
        olusturmaTarihi: siparis.olusturmaTarihi,
        // Nested create — sipariş + kalemleri TEK bir işlemde yazılır,
        // aradan bir hata çıkarsa (örn. bağlantı kopması) yarım sipariş
        // kalmaz. Prisma bunu kendi içinde tek transaction'a çeviriyor.
        kalemler: {
          create: kalemler.map((kalem) => ({ menuOgesiId: kalem.menuOgesiId, adet: kalem.adet })),
        },
      },
    });
    return this.sipariseCevir(kayit);
  }

  async idIleBul(id: string): Promise<CookzoneSiparis | null> {
    const kayit = await this.prisma.cookzoneSiparis.findUnique({ where: { id } });
    return kayit ? this.sipariseCevir(kayit) : null;
  }

  async kullaniciyaGoreListele(kullaniciId: string): Promise<CookzoneSiparis[]> {
    const kayitlar = await this.prisma.cookzoneSiparis.findMany({
      where: { kullaniciId },
      orderBy: { alinmaSaati: 'desc' },
    });
    return kayitlar.map((kayit) => this.sipariseCevir(kayit));
  }

  async isletmeyeGoreListele(isletmeId: string): Promise<CookzoneSiparis[]> {
    const kayitlar = await this.prisma.cookzoneSiparis.findMany({
      where: { isletmeId },
      orderBy: { alinmaSaati: 'asc' },
    });
    return kayitlar.map((kayit) => this.sipariseCevir(kayit));
  }

  async durumGuncelle(id: string, durum: CookzoneSiparisDurumu): Promise<CookzoneSiparis> {
    const kayit = await this.prisma.cookzoneSiparis.update({
      where: { id },
      data: { durum: durum as PrismaDurum },
    });
    return this.sipariseCevir(kayit);
  }

  async kalemleriGetir(siparisId: string): Promise<CookzoneSiparisKalemi[]> {
    const kayitlar = await this.prisma.cookzoneSiparisKalemi.findMany({
      where: { siparisId },
      include: { menuOgesi: true },
    });
    return kayitlar.map(
      (kayit) =>
        new CookzoneSiparisKalemi(
          kayit.id,
          kayit.siparisId,
          kayit.menuOgesiId,
          kayit.menuOgesi.ad,
          Number(kayit.menuOgesi.fiyat),
          kayit.adet,
        ),
    );
  }

  private sipariseCevir(kayit: SiparisKaydi): CookzoneSiparis {
    return new CookzoneSiparis(
      kayit.id,
      kayit.kullaniciId,
      kayit.isletmeId,
      kayit.durum,
      Number(kayit.toplamTutar),
      kayit.alinmaSaati,
      kayit.olusturmaTarihi,
    );
  }
}
