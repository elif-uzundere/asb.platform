import { Module } from '@nestjs/common';

import { AcilDurumService } from './application';
import { AcilDurumRepository } from './domain';
import { PrismaAcilDurumRepository } from './adapters/persistence';
import { AcilDurumController } from './adapters/web';

@Module({
  controllers: [
    AcilDurumController,
  ],
  providers: [
    AcilDurumService,
    {
      provide: AcilDurumRepository,
      useClass: PrismaAcilDurumRepository,
    },
  ],
})
export class AcilDurumModule {}