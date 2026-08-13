import { Module } from '@nestjs/common';
import { PrismaService } from '../../shared/infrastructure/prisma.service';
import { PrismaBolgeNoktasiRepository } from './adapters/persistence/prisma-bolge-noktasi.repository';
import { BolgeNoktasiSorgulamaAdapter } from './adapters/public';
import { BOLGE_NOKTASI_REPOSITORY, BOLGE_NOKTASI_SORGULAMA_PORT } from './harita.tokens';

// Tam navigasyon özelliği (rota/harita ekranı) henüz yazılmadı — bu modül
// şimdilik sadece `BOLGE_NOKTASI_SORGULAMA_PORT`'u dışa açıyor (Cookzone
// gibi modüllerin "bu işletme nerede" ihtiyacı için). Gerçek Harita modülü
// yazıldığında bu port zaten oradan besleniyor olacak.
@Module({
  providers: [
    PrismaService,
    { provide: BOLGE_NOKTASI_REPOSITORY, useClass: PrismaBolgeNoktasiRepository },
    { provide: BOLGE_NOKTASI_SORGULAMA_PORT, useClass: BolgeNoktasiSorgulamaAdapter },
  ],
  exports: [BOLGE_NOKTASI_SORGULAMA_PORT],
})
export class HaritaModule {}
