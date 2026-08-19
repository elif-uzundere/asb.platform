import {
  BadRequestException,
  Body,
  Controller,
  FileTypeValidator,
  Get,
  Inject,
  MaxFileSizeValidator,
  ParseFilePipe,
  Post,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';

import {
  ApiBearerAuth,
  ApiTags,
} from '@nestjs/swagger';

import { IkinciElPazarService } from '../../application';
import { IkinciElIlaniOlusturDto } from '../../dto';

import { AktifKullaniciBilgisi } from '../../../../shared/web/aktif-kullanici.decorator';
import type { AktifKullanici } from '../../../../shared/web/jwt-icerigi';
import { Yetki } from '../../../../shared/web/yetki.decorator';
import { YetkiGuard } from '../../../../shared/web/yetki.guard';
import { YETKILER } from '@asb/shared-types';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { FILE_STORAGE_PORT, FileStoragePort } from '../../../../shared/infrastructure/file-storage/file-storage.port';

// En az 1, en fazla 10 fotoğraf ("sahibinden gibi" — 18.08.2026, Berzan'ın
// isteği). Palet Tesisi'ndeki tek-dosya doğrulamasıyla aynı boyut/tip kuralı.
const FOTOGRAF_DOGRULAMA = new ParseFilePipe({
  validators: [
    new MaxFileSizeValidator({ maxSize: 5 * 1024 * 1024, message: 'Her fotoğraf en fazla 5 MB olabilir' }),
    new FileTypeValidator({ fileType: /^image\/(jpeg|png|webp)$/ }),
  ],
  fileIsRequired: false,
});

@ApiTags('İkinci El Pazar')
@Controller('ikinci-el-pazar')
export class IkinciElPazarController {
  constructor(
    private readonly ikinciElPazarService:
      IkinciElPazarService,
    @Inject(FILE_STORAGE_PORT) private readonly fileStorage: FileStoragePort,
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
   * İlan girme izni artık role sabit DEĞİL — RolYetki üzerinden
   * `ikinci_el_yonet` yetkisine sahip herhangi bir rol ilan girebilir
   * (admin panelinden atanır, bkz. seed.ts'te varsayılan admin/firma_yetkilisi).
   */
  @Post()
  @ApiBearerAuth()
  @UseGuards(YetkiGuard)
  @Yetki(YETKILER.IKINCI_EL_YONET)
  @UseInterceptors(FilesInterceptor('fotograflar', 10))
  async ilanOlustur(
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
    @Body() dto: IkinciElIlaniOlusturDto,
    @UploadedFiles(FOTOGRAF_DOGRULAMA) fotograflar?: Express.Multer.File[],
  ) {
    if (!fotograflar || fotograflar.length === 0) {
      throw new BadRequestException('En az bir fotoğraf eklenmelidir');
    }

    const fotografUrls = await Promise.all(
      fotograflar.map((dosya) => this.fileStorage.upload(dosya.originalname, dosya.buffer)),
    );

    const ilan =
      await this.ikinciElPazarService.ilanOlustur(
        kullanici.id,
        dto,
        fotografUrls,
      );

    return ApiResponseDto.ok(ilan);
  }
}
