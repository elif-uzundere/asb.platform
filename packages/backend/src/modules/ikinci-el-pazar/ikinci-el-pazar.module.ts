import { Module } from '@nestjs/common';

import { IkinciElPazarService } from './application';
import { PrismaIkinciElRepository } from './adapters/persistence';
import { IkinciElPazarController } from './adapters/web';
import { IkinciElRepository } from './domain';

@Module({
  controllers: [
    IkinciElPazarController,
  ],
  providers: [
    IkinciElPazarService,
    {
      provide: IkinciElRepository,
      useClass: PrismaIkinciElRepository,
    },
  ],
})
export class IkinciElPazarModule {}