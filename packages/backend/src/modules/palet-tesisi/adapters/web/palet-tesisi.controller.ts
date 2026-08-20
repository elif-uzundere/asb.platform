import {
  Body,
  Controller,
  FileTypeValidator,
  Get,
  Inject,
  MaxFileSizeValidator,
  NotFoundException,
  Param,
  ParseFilePipe,
  Post,
  Put,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { YETKILER } from '@asb/shared-types';

import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { Yetki } from '../../../../shared/web/yetki.decorator';
import { YetkiGuard } from '../../../../shared/web/yetki.guard';
import { FILE_STORAGE_PORT, FileStoragePort } from '../../../../shared/infrastructure/file-storage/file-storage.port';
import { PaletTesisiService } from '../../application';
import { PaletBulunamadiException } from '../../domain';
import { PaletOlusturDto } from './palet-olustur.dto';
import { PaletGuncelleDto } from './palet-guncelle.dto';

// Yalnızca görsel dosyaları, uygun format ve boyutlarda tek yükleme.
// 5 MB üstü ya da bu 3 tip dışındaki dosyalar ParseFilePipe tarafından
// otomatik BadRequestException ile reddedilir. `fileIsRequired: false`
// olduğu için görselsiz de olur.
const GORSEL_DOGRULAMA = new ParseFilePipe({
  validators: [
    new MaxFileSizeValidator({ maxSize: 5 * 1024 * 1024, message: 'Görsel en fazla 5 MB olabilir' }),
    new FileTypeValidator({ fileType: /^image\/(jpeg|png|webp)$/ }),
  ],
  fileIsRequired: false,
});

@ApiTags('Palet Tesisi')
@ApiBearerAuth()
@Controller('palet-tesisi')
export class PaletTesisiController {
  constructor(
    private readonly paletTesisiService: PaletTesisiService,
    @Inject(FILE_STORAGE_PORT) private readonly fileStorage: FileStoragePort,
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

  /**
   * `/paletler/:id`'den önce tanımlı olması gerekmiyor, bilerek `/paletler`
   * altında farklı bir literal segment. NestJS metoda göre değil, path+method'a
   * göre eşleştirir. `GET /paletler/tumu` ile bir `GET /paletler/:id` (yok, ama
   * ileride eklenirse) çakışmasın diye is-ilanlari.controller.ts'teki aynı
   * sıra kuralına uyuluyor.
   */
  @Get('paletler/tumu')
  @UseGuards(YetkiGuard)
  @Yetki(YETKILER.PALET_TESISI_YONET)
  async tumPaletleriGetir() {
    const paletler = await this.paletTesisiService.tumPaletleriGetir();
    return ApiResponseDto.ok(paletler);
  }

  @Post('paletler')
  @UseGuards(YetkiGuard)
  @Yetki(YETKILER.PALET_TESISI_YONET)
  @UseInterceptors(FileInterceptor('gorsel'))
  async paletOlustur(
    @Body() dto: PaletOlusturDto,
    @UploadedFile(GORSEL_DOGRULAMA) gorsel?: Express.Multer.File,
  ) {
    const gorselUrl = gorsel ? await this.fileStorage.upload(gorsel.originalname, gorsel.buffer) : null;
    const palet = await this.paletTesisiService.paletOlustur({
      ad: dto.ad,
      aciklama: dto.aciklama ?? null,
      olcu: dto.olcu ?? null,
      gorselUrl,
    });
    return ApiResponseDto.ok(palet);
  }

  /** Mevcut (örn. seed'den gelen, görselsiz) bir palet çeşidine sonradan
   * görsel eklemek de bu uçla yapılır — `gorsel` gönderilmezse sadece
   * metin alanları güncellenir, mevcut görsel korunur. */
  @Put('paletler/:id')
  @UseGuards(YetkiGuard)
  @Yetki(YETKILER.PALET_TESISI_YONET)
  @UseInterceptors(FileInterceptor('gorsel'))
  async paletGuncelle(
    @Param('id') id: string,
    @Body() dto: PaletGuncelleDto,
    @UploadedFile(GORSEL_DOGRULAMA) gorsel?: Express.Multer.File,
  ) {
    try {
      const gorselUrl = gorsel ? await this.fileStorage.upload(gorsel.originalname, gorsel.buffer) : undefined;
      const palet = await this.paletTesisiService.paletGuncelle(id, {
        ad: dto.ad,
        aciklama: dto.aciklama,
        olcu: dto.olcu,
        ...(gorselUrl !== undefined ? { gorselUrl } : {}),
      });
      return ApiResponseDto.ok(palet);
    } catch (hata) {
      if (hata instanceof PaletBulunamadiException) {
        throw new NotFoundException(hata.message);
      }
      throw hata;
    }
  }
}
