import { Module } from '@nestjs/common';

import { PaletTesisiService } from './application';
import { PaletTesisiRepository } from './domain';
import { PrismaPaletTesisiRepository } from './infrastructure';
import { PaletTesisiController } from './adapters/web';

@Module({
  controllers: [
    PaletTesisiController,
  ],

  providers: [
    PaletTesisiService,

    {
      provide: PaletTesisiRepository,
      useClass: PrismaPaletTesisiRepository,
    },
  ],

  exports: [
    PaletTesisiService,
  ],
})
export class PaletTesisiModule {}