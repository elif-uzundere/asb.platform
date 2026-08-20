import {
  BadRequestException,
  Body,
  Controller,
  Get,
  Inject,
  NotFoundException,
  Param,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { FirmaOnayKuyrugu, FirmaResponse } from '@asb/shared-types';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { JwtAuthGuard } from '../../../../shared/web/jwt-auth.guard';
import { Roller } from '../../../../shared/web/roller.decorator';
import { RollerGuard } from '../../../../shared/web/roller.guard';
import type { FirmaService } from '../../application';
import { Firma, FirmaBulunamadiException, FirmaZatenOnayliException } from '../../domain';
import { FIRMA_SERVICE } from '../../firma.tokens';
import { FirmaListeDto } from './firma-liste.dto';
import { FirmaOlusturDto } from './firma-olustur.dto';

@ApiTags('firma')
// `@UseGuards` gerçek korumayı sağlar (401/403). `@ApiBearerAuth()` ise
// sadece Swagger dokümantasyonu için. Bu olmadan endpoint gerçekte korumalı
// kalır ama Swagger UI "bu endpoint token ister" bilmediği için Authorize'daki
// token'ı isteğe hiç eklemez, kilit ikonu da görünmez. İkisi ayrı şeyler:
// biri çalışma zamanı güvenliği, diğeri sadece dokümantasyon/test kolaylığı.
@ApiBearerAuth()
// Bilerek controller seviyesinde guard yok. Katalog modeli bu: bir ziyaretçi
// giriş yapmadan firmaları görebilmeli. Guard sadece state değiştiren/
// kişiye-özel metotlarda tek tek yazılı (bkz. docs/YENI-MODUL-REHBERI.md
// "Okuma açık, yazma korumalı"). Bu controller'da eskiden class-level guard
// vardı, GET'leri de kilitliyordu. Bu hata canlı testte bulunup düzeltildi,
// bir daha tekrarlanmasın diye rehbere not düşüldü.
@Controller('firmalar')
export class FirmaController {
  constructor(@Inject(FIRMA_SERVICE) private readonly firmaService: FirmaService) {}

  @Get()
  async listele(@Query() filtre: FirmaListeDto): Promise<ApiResponseDto<FirmaResponse[]>> {
    const firmalar = await this.firmaService.listele(filtre);
    return ApiResponseDto.ok(firmalar.map((firma) => this.yanitaCevir(firma)));
  }

  /**
   * DİKKAT — SIRA ÖNEMLİ: Bu metot `@Get(':id')`'den ÖNCE tanımlı olmak
   * zorunda. NestJS rotaları tanımlanma sırasına göre eşleştirir; ':id' üstte
   * olsaydı `/firmalar/sektorler` isteği "sektorler" kelimesini bir id sanıp
   * 404 dönerdi. (Bu hatayı canlı testte gördük, böyle çözüldü.)
   */
  @Get('sektorler')
  async sektorler(): Promise<ApiResponseDto<string[]>> {
    return ApiResponseDto.ok(await this.firmaService.sektorler());
  }

  /** Onay kuyruğu — sadece admin görmeli, tek tek korumalı. */
  @Get('onay-bekleyenler')
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller('admin')
  async onayBekleyenler(): Promise<ApiResponseDto<FirmaOnayKuyrugu[]>> {
    const firmalar = await this.firmaService.onayBekleyenler();
    return ApiResponseDto.ok(firmalar.map((firma) => this.kuyrukYanitinaCevir(firma)));
  }

  @Get(':id')
  async detay(@Param('id') id: string): Promise<ApiResponseDto<FirmaResponse>> {
    try {
      const firma = await this.firmaService.detay(id);
      return ApiResponseDto.ok(this.yanitaCevir(firma));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  @Post()
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller('admin')
  async olustur(@Body() dto: FirmaOlusturDto): Promise<ApiResponseDto<FirmaOnayKuyrugu>> {
    const firma = await this.firmaService.olustur(dto);
    // onayDurumu'nu admin'e geri veriyoruz: BR-1 gereği 'beklemede' geldiğini
    // görmesi lazım, yoksa "kaydettim ama listede yok" diye şaşırır.
    return ApiResponseDto.ok(this.kuyrukYanitinaCevir(firma));
  }

  @Put(':id/onayla')
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller('admin')
  async onayla(@Param('id') id: string): Promise<ApiResponseDto<FirmaOnayKuyrugu>> {
    try {
      const firma = await this.firmaService.onayla(id);
      return ApiResponseDto.ok(this.kuyrukYanitinaCevir(firma));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  /**
   * Domain exception'larını HTTP karşılıklarına çevirir.
   * Domain katmanı HTTP bilmez (mimari kural 2) — bu çeviri adapter'ın işi.
   * GlobalExceptionFilter sonrasında bunları ApiResponseDto zarfına sarıyor.
   */
  private httpHatasinaCevir(hata: unknown): unknown {
    if (hata instanceof FirmaBulunamadiException) {
      return new NotFoundException(hata.message);
    }
    if (hata instanceof FirmaZatenOnayliException) {
      return new BadRequestException(hata.message);
    }
    return hata;
  }

  /** Herkese açık yanıt — `onayDurumu` ve `aktif` BİLEREK yok (iç durum sızmaz). */
  private yanitaCevir(firma: Firma): FirmaResponse {
    return {
      id: firma.id,
      ad: firma.ad,
      logoUrl: firma.logoUrl,
      sektor: firma.sektor,
      adres: firma.adres,
      telefon: firma.telefon,
      eposta: firma.eposta,
      webAdres: firma.webAdres,
      kurulusTarihi: firma.kurulusTarihi ? firma.kurulusTarihi.toISOString() : null,
      personelSayisi: firma.personelSayisi,
      guncellemeTarihi: firma.guncellemeTarihi.toISOString(),
    };
  }

  /** Admin yanıtı — herkese açık alanlar + onay durumu. */
  private kuyrukYanitinaCevir(firma: Firma): FirmaOnayKuyrugu {
    return { ...this.yanitaCevir(firma), onayDurumu: firma.onayDurumu };
  }
}
