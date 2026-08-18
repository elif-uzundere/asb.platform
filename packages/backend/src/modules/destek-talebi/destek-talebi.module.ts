import { Module } from '@nestjs/common';
import { PrismaService } from '../../shared/infrastructure/prisma.service';

import { DestekTalebiService } from './application';
import { DestekTalebiRepository } from './domain';
import { PrismaDestekTalebiRepository } from './adapters/persistence';
import { DestekTalebiController } from './adapters/web';
import { AuthModule } from '../auth/auth.module';
import { KULLANICI_SORGULAMA_PORT } from '../auth/auth.tokens';
import type { KullaniciSorgulamaPort } from '../auth/adapters/public/kullanici-sorgulama.port';
import { BILDIRIM_GONDER_PORT, BildirimGonderPort } from '../../shared/infrastructure/bildirim/bildirim-gonder.port';

// `AuthModule` sadece `KULLANICI_SORGULAMA_PORT`'a erişmek için import
// ediliyor (is-ilanlari.module.ts'teki aynı gerekçe). `BILDIRIM_GONDER_PORT`
// ise `BildirimModule` @Global olduğu için burada ayrıca import edilmiyor.
@Module({
  imports: [AuthModule],
  controllers: [DestekTalebiController],

  providers: [
    PrismaService,

    {
      provide: DestekTalebiRepository,
      useClass: PrismaDestekTalebiRepository,
    },
    {
      provide: DestekTalebiService,
      useFactory: (
        destekTalebiRepository: DestekTalebiRepository,
        bildirimGonder: BildirimGonderPort,
        kullaniciSorgulama: KullaniciSorgulamaPort,
      ) => new DestekTalebiService(destekTalebiRepository, bildirimGonder, kullaniciSorgulama),
      inject: [DestekTalebiRepository, BILDIRIM_GONDER_PORT, KULLANICI_SORGULAMA_PORT],
    },
  ],
})
export class DestekTalebiModule {}
