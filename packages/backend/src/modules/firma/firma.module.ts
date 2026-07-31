import { Module } from '@nestjs/common';
import { PrismaService } from '../../shared/infrastructure/prisma.service';
import { FirmaService } from './application';
import { FirmaRepository } from './domain';
import { PrismaFirmaRepository } from './adapters/persistence';
import { FirmaController } from './adapters/web';
import { FirmaSorgulamaAdapter } from './adapters/public';
import { FIRMA_REPOSITORY, FIRMA_SERVICE, FIRMA_SORGULAMA_PORT } from './firma.tokens';

// `GuvenlikModule` BURADA import EDİLMİYOR — o modül @Global, guard'lar
// zaten her yerde çözülüyor. Açıkça import etmek gereksiz tekrar olurdu.
//
// Nest'e bağlama (wiring) sadece bu dosyada. `domain` ve `application`
// katmanları decorator görmüyor (mimari kural 2); somut sınıflar soyut
// arayüzlere burada, token'lar üzerinden bağlanıyor.
@Module({
  controllers: [FirmaController],
  providers: [
    PrismaService,

    // Soyut arayüz → somut Prisma implementasyonu. Servis hangi veritabanını
    // kullandığımızı bilmiyor; yarın başka bir adapter yazılsa servis değişmez
    // (Dependency Inversion).
    { provide: FIRMA_REPOSITORY, useClass: PrismaFirmaRepository },

    // FirmaService saf TS olduğu için `useClass` ile kurulamaz (Nest onun
    // constructor'ını okuyamaz) — elle `useFactory` ile kuruyoruz.
    {
      provide: FIRMA_SERVICE,
      useFactory: (repo: FirmaRepository) => new FirmaService(repo),
      inject: [FIRMA_REPOSITORY],
    },

    { provide: FIRMA_SORGULAMA_PORT, useClass: FirmaSorgulamaAdapter },
  ],
  // Dışa açılan TEK şey bu port. `is-ilanlari` modülü BR-2 için ("bu firma
  // onaylı mı?") bunu kullanacak; firma'nın domain/persistence katmanı
  // dışarıya kapalı kalıyor (mimari kural 3).
  exports: [FIRMA_SORGULAMA_PORT],
})
export class FirmaModule {}
