import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { GlobalExceptionFilter } from './shared/web/global-exception.filter';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({ origin: true });

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
