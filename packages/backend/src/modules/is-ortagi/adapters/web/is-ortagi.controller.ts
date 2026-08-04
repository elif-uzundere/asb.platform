import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';

import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { IsOrtagiService } from '../../application';
import type { IsOrtagiData } from '../../domain';

@ApiTags('İş Ortakları')
@Controller('is-ortaklari')
export class IsOrtagiController {
  constructor(
    private readonly isOrtagiService: IsOrtagiService,
  ) {}

  @Get()
  @ApiOperation({
    summary: 'Tüm iş ortaklarını listeler',
  })
  async tumunuGetir(): Promise<ApiResponseDto<IsOrtagiData[]>> {
    const isOrtaklari =
        await this.isOrtagiService.tumunuGetir();

    return ApiResponseDto.ok(isOrtaklari);
  }
}