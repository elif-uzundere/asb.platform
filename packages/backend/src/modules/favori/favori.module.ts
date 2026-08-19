import { Module } from '@nestjs/common';
import { PrismaService } from '../../shared/infrastructure/prisma.service';

import { FavoriService } from './application';
import { FavoriRepository } from './domain';
import { PrismaFavoriRepository } from './adapters/persistence';
import { FavoriController } from './adapters/web';
import { FavoriSorgulamaAdapter } from './adapters/public';
import { FAVORI_REPOSITORY, FAVORI_SERVICE, FAVORI_SORGULAMA_PORT } from './favori.tokens';

@Module({
  controllers: [FavoriController],
  providers: [
    PrismaService,
    { provide: FAVORI_REPOSITORY, useClass: PrismaFavoriRepository },
    {
      provide: FAVORI_SERVICE,
      useFactory: (favoriRepository: FavoriRepository) => new FavoriService(favoriRepository),
      inject: [FAVORI_REPOSITORY],
    },
    { provide: FAVORI_SORGULAMA_PORT, useClass: FavoriSorgulamaAdapter },
  ],
  // `is-ilanlari` gibi diğer modüllerin `FAVORI_SORGULAMA_PORT`'a erişebilmesi
  // için (favoriSayisi göstermek amacıyla) — kullanici-sorgulama.port.ts'teki
  // aynı desen.
  exports: [FAVORI_SORGULAMA_PORT],
})
export class FavoriModule {}
