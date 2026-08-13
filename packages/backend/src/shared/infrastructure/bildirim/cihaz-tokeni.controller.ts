import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { ApiResponseDto } from '../../web/api-response.dto';
import { JwtAuthGuard } from '../../web/jwt-auth.guard';
import { AktifKullaniciBilgisi } from '../../web/aktif-kullanici.decorator';
import type { AktifKullanici } from '../../web/jwt-icerigi';
import { CihazTokeniService } from './cihaz-tokeni.service';
import { CihazTokeniKaydetDto } from './cihaz-tokeni-kaydet.dto';

@ApiTags('bildirim')
@ApiBearerAuth()
@Controller('bildirim')
export class CihazTokeniController {
  constructor(private readonly cihazTokeniService: CihazTokeniService) {}

  /** Kişiye özel — girişsiz bir cihaz token'ının kimin olduğu bilinemez. */
  @Post('cihaz-tokeni')
  @UseGuards(JwtAuthGuard)
  async kaydet(
    @Body() dto: CihazTokeniKaydetDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<null>> {
    await this.cihazTokeniService.kaydet(kullanici.id, dto.token, dto.platform);
    return ApiResponseDto.ok(null);
  }
}
