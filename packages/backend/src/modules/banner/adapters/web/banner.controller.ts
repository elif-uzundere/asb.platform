import { Controller, Get } from '@nestjs/common';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { BannerData, BannerRepository } from '../../domain';

@Controller('banners')
export class BannerController {
  constructor(private readonly bannerRepository: BannerRepository) {}

  @Get()
  async bannerlariGetir(): Promise<ApiResponseDto<BannerData[]>> {
    const bannerlar = await this.bannerRepository.aktifBannerlariGetir();
    return ApiResponseDto.ok(bannerlar);
  }
}