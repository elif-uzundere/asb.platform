import { Module } from '@nestjs/common';
import { PrismaService } from '../../shared/infrastructure/prisma.service';

import { DestekTalebiRepository } from './domain';
import { PrismaDestekTalebiRepository } from './adapters/persistence';
import { DestekTalebiController } from './adapters/web';

@Module({
  controllers: [DestekTalebiController],

  providers: [
    PrismaService,

    {
      provide: DestekTalebiRepository,
      useClass: PrismaDestekTalebiRepository,
    },
  ],
})
export class DestekTalebiModule {}
