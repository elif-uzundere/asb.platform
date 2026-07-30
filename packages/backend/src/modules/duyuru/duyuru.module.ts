import { Module } from '@nestjs/common';
import { PrismaService } from '../../shared/infrastructure/prisma.service';

import { DuyuruRepository } from './domain';
import { PrismaDuyuruRepository } from './adapters/persistence';
import { DuyuruController } from './adapters/web';

@Module({
  controllers: [DuyuruController],

  providers: [
    PrismaService,

    {
      provide: DuyuruRepository,
      useClass: PrismaDuyuruRepository,
    },
  ],
})
export class DuyuruModule {}