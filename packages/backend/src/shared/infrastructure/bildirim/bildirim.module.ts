import { Global, Module } from '@nestjs/common';
import { PrismaService } from '../prisma.service';
import { BILDIRIM_GONDER_PORT } from './bildirim-gonder.port';
import { KonsolBildirimAdapter } from './konsol-bildirim.adapter';
import { CihazTokeniService } from './cihaz-tokeni.service';
import { CihazTokeniController } from './cihaz-tokeni.controller';

// `FileStorageModule` ile aynı desen: @Global, port tek yerden sağlanıyor.
// Gerçek FCM adapter'ı gelince burada SADECE `useClass` satırı değişecek.
@Global()
@Module({
  controllers: [CihazTokeniController],
  providers: [
    PrismaService,
    CihazTokeniService,
    { provide: BILDIRIM_GONDER_PORT, useClass: KonsolBildirimAdapter },
  ],
  exports: [BILDIRIM_GONDER_PORT],
})
export class BildirimModule {}
