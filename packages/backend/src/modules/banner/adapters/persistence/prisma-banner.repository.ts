import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import { BannerData, BannerRepository } from '../../domain';

@Injectable()
export class PrismaBannerRepository extends BannerRepository {
  constructor(private readonly prisma: PrismaService) {
    super();
  }

  async aktifBannerlariGetir(): Promise<BannerData[]> {
    return this.prisma.banner.findMany({
      where: {
        aktif: true,
      },
      orderBy: {
        sira: 'asc',
      },
      select: {
        id: true,
        gorselUrl: true,
        linkUrl: true,
        sira: true,
      },
    });
  }
}