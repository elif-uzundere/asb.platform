import { BadRequestException, Body, Controller, ForbiddenException, Get, Inject, NotFoundException, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';

import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { JwtAuthGuard } from '../../../../shared/web/jwt-auth.guard';
import { Roller } from '../../../../shared/web/roller.decorator';
import { RollerGuard } from '../../../../shared/web/roller.guard';
import { AktifKullaniciBilgisi } from '../../../../shared/web/aktif-kullanici.decorator';
import type { AktifKullanici } from '../../../../shared/web/jwt-icerigi';
import { AcilDurumService } from '../../application';
import { AciklamaZorunluException, AcilDurumBildirimi, BaskaEkibeAitException, BildirimBulunamadiException } from '../../domain';
import type { KullaniciSorgulamaPort } from '../../../auth/adapters/public/kullanici-sorgulama.port';
import { KULLANICI_SORGULAMA_PORT } from '../../../auth/auth.tokens';
import { AcilDurumBildirimiOlusturDto } from './acil-durum-bildirimi-olustur.dto';
import { AcilDurumBildirimDurumGuncelleDto } from './acil-durum-bildirim-durum-guncelle.dto';

// Ekip rollerini tek yerde topluyor, 6 rolü her @Roller() çağrısında elle
// yazmamak için.
const ACIL_DURUM_EKIP_ROLLERI = [
  'itfaiye_ekibi',
  'guvenlik_ekibi',
  'tekin_isg_ekibi',
  'kantar_ekibi',
  'gumruk_ekibi',
  'sirket_isg_ekibi',
] as const;

@ApiTags('Acil Durum')
@ApiBearerAuth()
@Controller('acil-durum')
export class AcilDurumController {
  constructor(
    private readonly acilDurumService: AcilDurumService,
    @Inject(KULLANICI_SORGULAMA_PORT) private readonly kullaniciSorgulama: KullaniciSorgulamaPort,
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

  /**
   * Ekip görünümü — girişteki hesabın rolüne (itfaiye_ekibi, guvenlik_ekibi,
   * tekin_isg_ekibi, kantar_ekibi, gumruk_ekibi, sirket_isg_ekibi) karşılık
   * gelen türün tüm bildirimleri. `/bildirimler`'den önce tanımlı olması
   * gerekmiyor, farklı bir literal segment ('ekip/...') olduğu için çakışma
   * riski yok.
   */
  @Get('ekip/bildirimler')
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller(...ACIL_DURUM_EKIP_ROLLERI)
  async ekibeGelenBildirimleriGetir(@AktifKullaniciBilgisi() kullanici: AktifKullanici) {
    const bildirimler = await this.acilDurumService.ekibeGelenBildirimleriGetir(kullanici.rol);
    const yanitlar = await Promise.all(bildirimler.map((bildirim) => this.ekipYanitinaCevir(bildirim)));
    return ApiResponseDto.ok(yanitlar);
  }

  @Put('ekip/bildirimler/:id/durum')
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller(...ACIL_DURUM_EKIP_ROLLERI)
  async bildirimDurumGuncelle(
    @Param('id') id: string,
    @Body() dto: AcilDurumBildirimDurumGuncelleDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ) {
    try {
      const bildirim = await this.acilDurumService.bildirimDurumGuncelle(id, dto.durum, kullanici.rol);
      return ApiResponseDto.ok(this.yanitaCevir(bildirim));
    } catch (hata) {
      if (hata instanceof BildirimBulunamadiException) {
        throw new NotFoundException(hata.message);
      }
      if (hata instanceof BaskaEkibeAitException) {
        throw new ForbiddenException(hata.message);
      }
      throw hata;
    }
  }

  private yanitaCevir(bildirim: AcilDurumBildirimi) {
    return {
      id: bildirim.id,
      tur: bildirim.tur,
      aciklama: bildirim.aciklama,
      durum: bildirim.durum,
      olusturmaTarihi: bildirim.olusturmaTarihi.toISOString(),
    };
  }

  private async ekipYanitinaCevir(bildirim: AcilDurumBildirimi) {
    const adSoyad = await this.kullaniciSorgulama.adSoyadGetir(bildirim.kullaniciId);
    return {
      ...this.yanitaCevir(bildirim),
      bildirenAdSoyad: adSoyad ?? 'Bilinmeyen Kullanıcı',
    };
  }
}
