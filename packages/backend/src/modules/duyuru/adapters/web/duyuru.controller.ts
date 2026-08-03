import { Body, Controller, Get, Param, Post, Req, UseGuards } from '@nestjs/common';
import { ApiBearerAuth } from '@nestjs/swagger';
import { YETKILER } from '@asb/shared-types';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { Yetki } from '../../../../shared/web/yetki.decorator';
import { YetkiGuard } from '../../../../shared/web/yetki.guard';
import { DuyuruData, DuyuruRepository } from '../../domain';
import { DuyuruOlusturDto } from './duyuru-olustur.dto';

interface YetkiliIstek {
  user: {
    sub: string;
    email: string;
    rol: string;
  };
}

@Controller('duyurular')
export class DuyuruController {
  constructor(private readonly duyuruRepository: DuyuruRepository) {}

  @Get()
  async tumDuyurulariGetir(): Promise<ApiResponseDto<DuyuruData[]>> {
    const duyurular = await this.duyuruRepository.tumDuyurulariGetir();
    return ApiResponseDto.ok(duyurular);
  }

  @Get(':id')
  async duyuruGetir(@Param('id') id: string): Promise<ApiResponseDto<DuyuruData | null>> {
    const duyuru = await this.duyuruRepository.duyuruGetir(id);
    return ApiResponseDto.ok(duyuru);
  }

  /**
   * `duyuru_yonet` yetkisine sahip roller duyuru yayınlayabilir (bkz.
   * `rol_yetki` tablosu / seed.ts) — bu illa `admin` demek değil, ileride
   * başka bir role bu yetki tanımlanırsa kod değişikliği gerekmez.
   */
  @Post()
  @ApiBearerAuth()
  @UseGuards(YetkiGuard)
  @Yetki(YETKILER.DUYURU_YONET)
  async duyuruOlustur(
    @Body() dto: DuyuruOlusturDto,
    @Req() istek: YetkiliIstek,
  ): Promise<ApiResponseDto<DuyuruData>> {
    const duyuru = await this.duyuruRepository.duyuruOlustur({
      baslik: dto.baslik,
      icerik: dto.icerik,
      kategori: dto.kategori,
      ...(dto.yayinTarihi ? { yayinTarihi: new Date(dto.yayinTarihi) } : {}),
      olusturanKullaniciId: istek.user.sub,
    });

    return ApiResponseDto.ok(duyuru);
  }
}
