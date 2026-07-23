import { Module } from '@nestjs/common';
import { PrismaModule } from './shared/infrastructure/prisma.module';
import { FileStorageModule } from './shared/infrastructure/file-storage/file-storage.module';
import { HealthModule } from './shared/web/health.module';
import { AuthModule } from './modules/auth/auth.module';
import { FirmaModule } from './modules/firma/firma.module';
import { IsIlanlariModule } from './modules/is-ilanlari/is-ilanlari.module';
import { IkinciElPazarModule } from './modules/ikinci-el-pazar/ikinci-el-pazar.module';
import { CookzoneModule } from './modules/cookzone/cookzone.module';
import { AcilDurumModule } from './modules/acil-durum/acil-durum.module';
import { DuyuruModule } from './modules/duyuru/duyuru.module';
import { BannerModule } from './modules/banner/banner.module';
import { IsOrtaklariModule } from './modules/is-ortaklari/is-ortaklari.module';
import { PaketTeslimiModule } from './modules/paket-teslimi/paket-teslimi.module';
import { HaritaModule } from './modules/harita/harita.module';

@Module({
  imports: [
    PrismaModule,
    FileStorageModule,
    HealthModule,
    AuthModule,
    FirmaModule,
    IsIlanlariModule,
    IkinciElPazarModule,
    CookzoneModule,
    AcilDurumModule,
    DuyuruModule,
    BannerModule,
    IsOrtaklariModule,
    PaketTeslimiModule,
    HaritaModule,
  ],
})
export class AppModule {}
