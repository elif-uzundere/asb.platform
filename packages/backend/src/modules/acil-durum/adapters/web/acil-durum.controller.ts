import { BadRequestException, Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { JwtAuthGuard } from '../../../../shared/web/jwt-auth.guard';
import { AktifKullaniciBilgisi } from '../../../../shared/web/aktif-kullanici.decorator';
import type { AktifKullanici } from '../../../../shared/web/jwt-icerigi';
import { AcilDurumService } from '../../application';
import { AciklamaZorunluException } from '../../domain';
import { AcilDurumBildirimiOlusturDto } from './acil-durum-bildirimi-olustur.dto';

@ApiTags('Acil Durum')
@ApiBearerAuth()
@Controller('acil-durum')
export class AcilDurumController {
  constructor(
    private readonly acilDurumService: AcilDurumService,
  ) {}

  @Get('bilgiler')
  async bilgileriGetir() {
    const bilgiler =
        await this.acilDurumService.bilgileriGetir();

    return ApiResponseDto.ok(bilgiler);
  }

  @Get('toplanma-alanlari')
  async toplanmaAlanlariniGetir() {
    const alanlar =
        await this.acilDurumService.toplanmaAlanlariniGetir();

    return ApiResponseDto.ok(alanlar);
  }

  @Post('bildirimler')
  @UseGuards(JwtAuthGuard)
  async bildirimOlustur(
    @Body() dto: AcilDurumBildirimiOlusturDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ) {
    try {
      const bildirim = await this.acilDurumService.bildirimOlustur(kullanici.id, dto.tur, dto.aciklama);
      return ApiResponseDto.ok(this.yanitaCevir(bildirim));
    } catch (hata) {
      if (hata instanceof AciklamaZorunluException) {
        throw new BadRequestException(hata.message);
      }
      throw hata;
    }
  }

  @Get('bildirimlerim')
  @UseGuards(JwtAuthGuard)
  async bildirimlerimGetir(@AktifKullaniciBilgisi() kullanici: AktifKullanici) {
    const bildirimler = await this.acilDurumService.bildirimlerimGetir(kullanici.id);
    return ApiResponseDto.ok(bildirimler.map((bildirim) => this.yanitaCevir(bildirim)));
  }

  private yanitaCevir(bildirim: Awaited<ReturnType<AcilDurumService['bildirimOlustur']>>) {
    return {
      id: bildirim.id,
      tur: bildirim.tur,
      aciklama: bildirim.aciklama,
      durum: bildirim.durum,
      olusturmaTarihi: bildirim.olusturmaTarihi.toISOString(),
    };
  }
}