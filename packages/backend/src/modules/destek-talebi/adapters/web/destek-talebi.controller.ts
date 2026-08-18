import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { DestekTalebiResponse } from '@asb/shared-types';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { AktifKullaniciBilgisi } from '../../../../shared/web/aktif-kullanici.decorator';
import { AktifKullanici } from '../../../../shared/web/jwt-icerigi';
import { JwtAuthGuard } from '../../../../shared/web/jwt-auth.guard';
import { DestekTalebiService } from '../../application';
import { DestekTalebiOlusturDto } from './destek-talebi-olustur.dto';

// Talep oluşturmak ve listelemek KİM olduğunu bilmeyi gerektirir (talep bir
// kullanıcıya ait) — bu yüzden sınıf seviyesinde JwtAuthGuard: girişsiz
// kimse bu uca hiç giremez.
@ApiTags('destek-talepleri')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('destek-talepleri')
export class DestekTalebiController {
  constructor(private readonly destekTalebiService: DestekTalebiService) {}

  @Post()
  async olustur(
    @Body() dto: DestekTalebiOlusturDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<DestekTalebiResponse>> {
    const talep = await this.destekTalebiService.olustur({
      baslik: dto.baslik,
      aciklama: dto.aciklama,
      kullaniciId: kullanici.id,
    });
    return ApiResponseDto.ok(this.yanitaCevir(talep));
  }

  @Get()
  async listele(
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<DestekTalebiResponse[]>> {
    const talepler = await this.destekTalebiService.kullaniciyaGoreListele(kullanici.id);
    return ApiResponseDto.ok(talepler.map((talep) => this.yanitaCevir(talep)));
  }

  private yanitaCevir(talep: {
    id: string;
    baslik: string;
    aciklama: string;
    durum: string;
    olusturmaTarihi: Date;
  }): DestekTalebiResponse {
    return {
      id: talep.id,
      baslik: talep.baslik,
      aciklama: talep.aciklama,
      durum: talep.durum as DestekTalebiResponse['durum'],
      olusturmaTarihi: talep.olusturmaTarihi.toISOString(),
    };
  }
}
