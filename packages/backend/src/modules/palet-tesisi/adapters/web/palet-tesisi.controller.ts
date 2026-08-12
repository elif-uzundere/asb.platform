import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';

import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { PaletTesisiService } from '../../application';

@ApiTags('Palet Tesisi')
@Controller('palet-tesisi')
export class PaletTesisiController {
  constructor(
    private readonly paletTesisiService: PaletTesisiService,
  ) {}

  @Get('bilgi')
  async tesisBilgisiGetir() {
    const bilgi =
        await this.paletTesisiService.tesisBilgisiGetir();

    return ApiResponseDto.ok(bilgi);
  }

  @Get('paletler')
  async paletleriGetir() {
    const paletler =
        await this.paletTesisiService.paletleriGetir();

    return ApiResponseDto.ok(paletler);
  }
}