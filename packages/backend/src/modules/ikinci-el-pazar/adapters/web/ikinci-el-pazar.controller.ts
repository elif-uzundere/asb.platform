import {
  Body,
  Controller,
  Get,
  Post,
  Req,
  UseGuards,
} from '@nestjs/common';

import {
  ApiBearerAuth,
  ApiTags,
} from '@nestjs/swagger';

import { IkinciElPazarService } from '../../application';
import { IkinciElIlaniOlusturDto } from '../../dto';

import {
  JwtAuthGuard,
  KullaniciliRequest,
} from '../../../../shared/web/jwt-auth.guard';

import { Roller } from '../../../../shared/web/roller.decorator';
import { RollerGuard } from '../../../../shared/web/roller.guard';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';

@ApiTags('İkinci El Pazar')
@Controller('ikinci-el-pazar')
export class IkinciElPazarController {
  constructor(
    private readonly ikinciElPazarService:
      IkinciElPazarService,
  ) {}

  /**
   * Herkes aktif ikinci el ilanlarını görebilir.
   */
  @Get()
  async aktifIlanlariGetir() {
    const ilanlar =
      await this.ikinciElPazarService.aktifIlanlariGetir();

    return ApiResponseDto.ok(ilanlar);
  }

  /**
   * Sadece admin ve firma_yetkilisi
   * yeni ilan oluşturabilir.
   */
  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller('admin', 'firma_yetkilisi')
  async ilanOlustur(
    @Req() request: KullaniciliRequest,
    @Body() dto: IkinciElIlaniOlusturDto,
  ) {
    const kullanici = request.kullanici!;

    const ilan =
      await this.ikinciElPazarService.ilanOlustur(
        kullanici.id,
        dto,
      );

    return ApiResponseDto.ok(ilan);
  }
}