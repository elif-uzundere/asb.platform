import { Body, Controller, Get, Inject, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { FavoriDurumDegistirResponse, FavoriHedefTuru, FavorilerimResponse } from '@asb/shared-types';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { JwtAuthGuard } from '../../../../shared/web/jwt-auth.guard';
import { AktifKullaniciBilgisi } from '../../../../shared/web/aktif-kullanici.decorator';
import type { AktifKullanici } from '../../../../shared/web/jwt-icerigi';
import type { FavoriService } from '../../application';
import { FAVORI_SERVICE } from '../../favori.tokens';
import { FavoriDurumDegistirDto } from './favori-durum-degistir.dto';

@ApiTags('favoriler')
@ApiBearerAuth()
@Controller('favoriler')
export class FavoriController {
  constructor(@Inject(FAVORI_SERVICE) private readonly favoriService: FavoriService) {}

  /** "Kalp" butonu — zaten favorideyse kaldırır, değilse ekler. */
  @Post()
  @UseGuards(JwtAuthGuard)
  async durumDegistir(
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
    @Body() dto: FavoriDurumDegistirDto,
  ): Promise<ApiResponseDto<FavoriDurumDegistirResponse>> {
    const sonuc = await this.favoriService.durumDegistir(kullanici.id, dto.hedefTuru, dto.hedefId);
    return ApiResponseDto.ok(sonuc);
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  async favorilerim(
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
    @Query('tur') tur: FavoriHedefTuru,
  ): Promise<ApiResponseDto<FavorilerimResponse>> {
    const idler = await this.favoriService.favorilerimGetir(kullanici.id, tur);
    return ApiResponseDto.ok(idler);
  }
}
