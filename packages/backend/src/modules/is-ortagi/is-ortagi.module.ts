import { Module } from '@nestjs/common';

import { PrismaIsOrtagiRepository } from './adapters/persistence';
import { IsOrtagiController } from './adapters/web';
import { IsOrtagiService } from './application';
import { IsOrtagiRepository } from './domain';

@Module({
  controllers: [IsOrtagiController],
  providers: [
    IsOrtagiService,
    PrismaIsOrtagiRepository,
    {
      provide: IsOrtagiRepository,
      useExisting: PrismaIsOrtagiRepository,
    },
  ],
})
export class IsOrtagiModule {}