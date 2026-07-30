import { Controller, Get, Param } from '@nestjs/common';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { DuyuruData, DuyuruRepository } from '../../domain';

@Controller('duyurular')
export class DuyuruController {
  constructor(
    private readonly duyuruRepository: DuyuruRepository,
  ) {}

  @Get()
  async tumDuyurulariGetir(): Promise<ApiResponseDto<DuyuruData[]>> {
    const duyurular =
      await this.duyuruRepository.tumDuyurulariGetir();

    return ApiResponseDto.ok(duyurular);
  }

  @Get(':id')
  async duyuruGetir(
    @Param('id') id: string,
  ): Promise<ApiResponseDto<DuyuruData | null>> {
    const duyuru =
      await this.duyuruRepository.duyuruGetir(id);

    return ApiResponseDto.ok(duyuru);
  }
}