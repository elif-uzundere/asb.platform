import { Module } from '@nestjs/common';
import { PrismaService } from '../../shared/infrastructure/prisma.service';
import { IsIlaniService } from './application';
import { IsIlaniRepository, IsBasvurusuRepository } from './domain';
import { PrismaIsIlaniRepository, PrismaIsBasvurusuRepository } from './adapters/persistence';
import { IsIlaniController } from './adapters/web';
import { IS_ILANI_REPOSITORY, IS_BASVURUSU_REPOSITORY, IS_ILANI_SERVICE } from './is-ilanlari.tokens';
import { FirmaModule } from '../firma/firma.module';
import { AuthModule } from '../auth/auth.module';
import { FIRMA_SORGULAMA_PORT } from '../firma/firma.tokens';
import type { FirmaSorgulamaPort } from '../firma/adapters/public/firma-sorgulama.port';
import { BILDIRIM_GONDER_PORT, BildirimGonderPort } from '../../shared/infrastructure/bildirim/bildirim-gonder.port';

// `FirmaModule` ve `AuthModule` import ediliyor — sadece bu iki modülün
// `exports` ettiği public port'lara (FIRMA_SORGULAMA_PORT,
// KULLANICI_SORGULAMA_PORT) erişmek için. Bu modüllerin domain/persistence
// katmanına hâlâ erişimimiz yok (mimari kural 3) — Nest'in DI container'ı
// sadece exports edilen provider'ları görünür kılıyor. `BILDIRIM_GONDER_PORT`
// ise `BildirimModule` @Global olduğu için burada ayrıca import edilmiyor.
@Module({
  imports: [FirmaModule, AuthModule],
  controllers: [IsIlaniController],
  providers: [
    PrismaService,
    { provide: IS_ILANI_REPOSITORY, useClass: PrismaIsIlaniRepository },
    { provide: IS_BASVURUSU_REPOSITORY, useClass: PrismaIsBasvurusuRepository },
    {
      provide: IS_ILANI_SERVICE,
      useFactory: (
        isIlaniRepo: IsIlaniRepository,
        basvuruRepo: IsBasvurusuRepository,
        firmaSorgulama: FirmaSorgulamaPort,
        bildirimGonder: BildirimGonderPort,
      ) => new IsIlaniService(isIlaniRepo, basvuruRepo, firmaSorgulama, bildirimGonder),
      inject: [IS_ILANI_REPOSITORY, IS_BASVURUSU_REPOSITORY, FIRMA_SORGULAMA_PORT, BILDIRIM_GONDER_PORT],
    },
  ],
})
export class IsIlanlariModule {}
