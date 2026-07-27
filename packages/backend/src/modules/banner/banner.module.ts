import { Module } from '@nestjs/common';
import { PrismaService } from '../../shared/infrastructure/prisma.service';
import { BannerRepository } from './domain';
import { PrismaBannerRepository } from './adapters/persistence';
import { BannerController } from './adapters/web';
@Module({  
 controllers: [BannerController],

  providers: [
    PrismaService,

    {
      provide: BannerRepository,
      useClass: PrismaBannerRepository,
    },
  ],
})
export class BannerModule {}
