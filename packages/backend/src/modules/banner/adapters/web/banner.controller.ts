import { Controller, Get } from '@nestjs/common';
import { BannerData, BannerRepository } from '../../domain';

@Controller('banners')
export class BannerController {
  constructor(private readonly bannerRepository: BannerRepository) {}

  @Get()
  bannerlariGetir(): Promise<BannerData[]> {
    return this.bannerRepository.aktifBannerlariGetir();
  }
}