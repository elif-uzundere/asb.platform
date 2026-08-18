import { Module } from '@nestjs/common';

import { AcilDurumService } from './application';
import { AcilDurumRepository } from './domain';
import { PrismaAcilDurumRepository } from './adapters/persistence';
import { AcilDurumController } from './adapters/web';
import { AuthModule } from '../auth/auth.module';
import { KULLANICI_SORGULAMA_PORT } from '../auth/auth.tokens';
import type { KullaniciSorgulamaPort } from '../auth/adapters/public/kullanici-sorgulama.port';
import { BILDIRIM_GONDER_PORT, BildirimGonderPort } from '../../shared/infrastructure/bildirim/bildirim-gonder.port';

// `AuthModule` sadece `KULLANICI_SORGULAMA_PORT`'a erişmek için import
// ediliyor (cookzone.module.ts'teki aynı gerekçe). `BILDIRIM_GONDER_PORT`
// ise `BildirimModule` @Global olduğu için burada ayrıca import edilmiyor.
@Module({
  imports: [AuthModule],
  controllers: [
    AcilDurumController,
  ],
  providers: [
    {
      provide: AcilDurumRepository,
      useClass: PrismaAcilDurumRepository,
    },
    {
      provide: AcilDurumService,
      useFactory: (
        acilDurumRepository: AcilDurumRepository,
        bildirimGonder: BildirimGonderPort,
        kullaniciSorgulama: KullaniciSorgulamaPort,
      ) => new AcilDurumService(acilDurumRepository, bildirimGonder, kullaniciSorgulama),
      inject: [AcilDurumRepository, BILDIRIM_GONDER_PORT, KULLANICI_SORGULAMA_PORT],
    },
  ],
})
export class AcilDurumModule {}
