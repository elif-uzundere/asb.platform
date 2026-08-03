// Guard'ları ve onların ihtiyaç duyduğu JwtService'i tüm uygulamaya sunar.
//
// Neden @Global()?
// `firma.module.ts` içinden `auth.module.ts`'i import EDEMEYİZ — .eslintrc.json'daki
// kural `module-root`'un başka bir `module-root`'u görmesine izin vermiyor
// (modüller birbirine zincirlenmesin diye). Ama `FirmaController`'ın
// `@UseGuards(JwtAuthGuard)` yazabilmesi için o guard'ın DI kabında bulunması
// gerekiyor.
//
// @Global() bu düğümü çözer: modül bir kez app.module.ts'e eklenir, sağladığı
// provider'lar her yerde enjekte edilebilir hâle gelir. Hiçbir modülün başka
// bir modülü import etmesi gerekmez.
//
// Bunu her modül için yapmak KÖTÜ olurdu (her şey global olursa modül sınırı
// diye bir şey kalmaz). Burada meşru: kimlik doğrulama gerçekten yatay bir
// kesit — her modülü ilgilendiriyor, hiçbirine ait değil.

import { Global, Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { JwtAuthGuard } from './jwt-auth.guard';
import { RollerGuard } from './roller.guard';
import { YetkiGuard } from './yetki.guard';

@Global()
@Module({
  imports: [
    // Token'ı `auth` modülü üretiyor, burada sadece DOĞRULANIYOR.
    // İkisinin ortak noktası aynı JWT_SECRET — kod bağımlılığı yok.
    // Secret'ların farklı olması imza doğrulamasını bozar, bu yüzden ikisi de
    // aynı env değişkenini okuyor.
    JwtModule.register({
      secret: process.env.JWT_SECRET ?? 'dev-secret-change-me',
    }),
  ],
  // YetkiGuard da burada — PrismaService (PrismaModule zaten @Global) ve
  // JwtService (üstteki JwtModule) ihtiyaçlarının ikisi de burada zaten
  // karşılanıyor, ayrı bir modülün import etmesine gerek yok.
  providers: [JwtAuthGuard, RollerGuard, YetkiGuard],
  // JwtModule de export edilmek ZORUNDA. Aksi halde guard her modüle görünür
  // olur ama bağımlılığı (JwtService) olmaz; Nest guard'ı tüketen modülün
  // bağlamında kurmaya çalışıp "can't resolve dependencies of the JwtAuthGuard"
  // hatasıyla açılışta düşer. Provider'ı dışa açarken bağımlılıklarını da
  // açmak gerekir — yoksa soyutlama yarım kalır.
  exports: [JwtAuthGuard, RollerGuard, YetkiGuard, JwtModule],
})
export class GuvenlikModule {}
