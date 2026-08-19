import { Injectable } from '@nestjs/common';
import type { FavoriHedefTuru } from '@asb/shared-types';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import { FavoriData, FavoriRepository } from '../../domain';

@Injectable()
export class PrismaFavoriRepository extends FavoriRepository {
  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async ekle(kullaniciId: string, hedefTuru: FavoriHedefTuru, hedefId: string): Promise<FavoriData> {
    // `upsert` — aynı favoriyi iki kez eklemeye çalışmak (ör. çift tıklama
    // yarışı) `@@unique` ihlali ile patlamasın diye idempotent.
    const kayit = await this.prisma.favori.upsert({
      where: { kullaniciId_hedefTuru_hedefId: { kullaniciId, hedefTuru, hedefId } },
      update: {},
      create: { kullaniciId, hedefTuru, hedefId },
    });
    return kayit;
  }

  async kaldir(kullaniciId: string, hedefTuru: FavoriHedefTuru, hedefId: string): Promise<void> {
    await this.prisma.favori.deleteMany({ where: { kullaniciId, hedefTuru, hedefId } });
  }

  async varMi(kullaniciId: string, hedefTuru: FavoriHedefTuru, hedefId: string): Promise<boolean> {
    const kayit = await this.prisma.favori.findUnique({
      where: { kullaniciId_hedefTuru_hedefId: { kullaniciId, hedefTuru, hedefId } },
    });
    return kayit !== null;
  }

  async kullanicininFavorileri(kullaniciId: string, hedefTuru: FavoriHedefTuru): Promise<string[]> {
    const kayitlar = await this.prisma.favori.findMany({
      where: { kullaniciId, hedefTuru },
      orderBy: { olusturmaTarihi: 'desc' },
      select: { hedefId: true },
    });
    return kayitlar.map((kayit) => kayit.hedefId);
  }

  async sayiGetir(hedefTuru: FavoriHedefTuru, hedefId: string): Promise<number> {
    return this.prisma.favori.count({ where: { hedefTuru, hedefId } });
  }
}
