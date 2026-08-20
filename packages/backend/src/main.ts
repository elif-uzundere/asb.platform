// `.env`'i process.env'e açıkça yükler. Önceden bu örtük olarak Prisma
// Client'ın kendi iç dotenv yüklemesine dayanıyordu, belgelenmemiş bir yan
// etkiydi. Bu satır aynı sonucu güvenilir ve görünür şekilde garanti eder.
import 'dotenv/config';
import { existsSync } from 'fs';
import { join } from 'path';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { ValidationPipe, VersioningType } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './shared/web/global-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  app.enableCors({ origin: true });

  // `LocalFileStorageAdapter` dosyaları `uploads/` altına yazıp `/uploads/...`
  // URL'i dönüyordu ama bunu HTTP üzerinden servis eden bir şey yoktu. CV
  // yükleme özelliğiyle ilk gerçek tüketici geldi, bu yüzden eklendi.
  // `setGlobalPrefix('api')` bunu etkilemiyor çünkü statik dosyalar
  // controller route'u değil, ayrı bir express middleware.
  app.useStaticAssets(join(process.cwd(), 'uploads'), { prefix: '/uploads/' });

  // Flutter Web build çıktısı sadece prod Docker imajında var (bkz.
  // Dockerfile'ın 3. aşaması, `web/` klasörüne kopyalanıyor). Geliştirme
  // ortamında (yerel `npm run start:dev`) bu klasör hiç yok. O yüzden
  // `existsSync` ile korunuyor. Yoksa Nest boş bir statik kök için hata
  // vermez ama gereksiz bir middleware eklemekten kaçınılmış olur. Prefiks
  // yok, uploads'tan farkı bu. Çünkü Flutter uygulaması hash routing
  // kullanıyor (`/#/giris` gibi). Sunucu tarafında bir yönlendirme/catch-all
  // rotasına gerek yok, `index.html` her zaman `/`de.
  const webDizini = join(process.cwd(), 'web');
  if (existsSync(webDizini)) {
    app.useStaticAssets(webDizini, { index: 'index.html' });
  }

  app.setGlobalPrefix('api');

  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  // DTO'lardaki class-validator kuralları ancak bu pipe ile işler.
  // Doğrulama hataları BadRequestException olarak fırlar; GlobalExceptionFilter
  // bunların `message` dizisini birleştirip ApiResponseDto zarfına sarıyor —
  // yani istemci tek bir response şekli görmeye devam ediyor.
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // DTO'da tanımsız alanları gövdeden düşür
      transform: true, // gövdeyi DTO örneğine dönüştür
    }),
  );

  app.useGlobalFilters(new GlobalExceptionFilter());

  const swaggerConfig = new DocumentBuilder()
    .setTitle('ASB Platform API')
    .setDescription('Avrupa Serbest Bölgesi hizmet platformu API dokümantasyonu')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/v1/docs', app, document);

  const port = process.env.PORT ? Number(process.env.PORT) : 3000;
  await app.listen(port);
}

bootstrap();
