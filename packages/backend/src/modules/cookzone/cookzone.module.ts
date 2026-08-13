import { Module } from '@nestjs/common';
import { PrismaService } from '../../shared/infrastructure/prisma.service';
import { BILDIRIM_GONDER_PORT, BildirimGonderPort } from '../../shared/infrastructure/bildirim/bildirim-gonder.port';
import { CookzoneService } from './application';
import { CookzoneIsletmeRepository, CookzoneSiparisRepository } from './domain';
import { PrismaCookzoneIsletmeRepository, PrismaCookzoneSiparisRepository } from './adapters/persistence';
import { CookzoneController } from './adapters/web';
import { COOKZONE_ISLETME_REPOSITORY, COOKZONE_SIPARIS_REPOSITORY, COOKZONE_SERVICE } from './cookzone.tokens';
import { HaritaModule } from '../harita/harita.module';
import { AuthModule } from '../auth/auth.module';

// `HaritaModule`/`AuthModule` sadece public port'larına (BOLGE_NOKTASI_
// SORGULAMA_PORT, KULLANICI_SORGULAMA_PORT) erişmek için import ediliyor —
// is-ilanlari.module.ts'teki aynı gerekçe. `BILDIRIM_GONDER_PORT` ise
// `BildirimModule` @Global olduğu için burada AYRICA import edilmiyor,
// otomatik görünür.
@Module({
  imports: [HaritaModule, AuthModule],
  controllers: [CookzoneController],
  providers: [
    PrismaService,
    { provide: COOKZONE_ISLETME_REPOSITORY, useClass: PrismaCookzoneIsletmeRepository },
    { provide: COOKZONE_SIPARIS_REPOSITORY, useClass: PrismaCookzoneSiparisRepository },
    {
      provide: COOKZONE_SERVICE,
      useFactory: (
        isletmeRepo: CookzoneIsletmeRepository,
        siparisRepo: CookzoneSiparisRepository,
        bildirimGonder: BildirimGonderPort,
      ) => new CookzoneService(isletmeRepo, siparisRepo, bildirimGonder),
      inject: [COOKZONE_ISLETME_REPOSITORY, COOKZONE_SIPARIS_REPOSITORY, BILDIRIM_GONDER_PORT],
    },
  ],
})
export class CookzoneModule {}
