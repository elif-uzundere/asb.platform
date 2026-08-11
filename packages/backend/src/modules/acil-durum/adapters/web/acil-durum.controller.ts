import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { AcilDurumService } from '../../application';

@ApiTags('Acil Durum')
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
}