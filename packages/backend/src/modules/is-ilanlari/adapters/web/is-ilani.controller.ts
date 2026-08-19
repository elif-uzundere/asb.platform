import {
  BadRequestException,
  Body,
  Controller,
  ForbiddenException,
  Get,
  Inject,
  NotFoundException,
  Param,
  Post,
  Put,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { YETKILER } from '@asb/shared-types';
import type { BasvurumResponse, IsBasvurusuResponse, IsIlaniResponse } from '@asb/shared-types';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { JwtAuthGuard } from '../../../../shared/web/jwt-auth.guard';
import { Yetki } from '../../../../shared/web/yetki.decorator';
import { YetkiGuard } from '../../../../shared/web/yetki.guard';
import { AktifKullaniciBilgisi } from '../../../../shared/web/aktif-kullanici.decorator';
import type { AktifKullanici } from '../../../../shared/web/jwt-icerigi';
import { FILE_STORAGE_PORT, FileStoragePort } from '../../../../shared/infrastructure/file-storage/file-storage.port';
import type { IsIlaniService } from '../../application';
import {
  IsIlani,
  IsBasvurusu,
  IsIlaniBulunamadiException,
  FirmaOnayliDegilException,
  BaskaFirmayaAitException,
  ZatenBasvurulduException,
  IlanKapaliException,
  BasvuruBulunamadiException,
} from '../../domain';
import type { KullaniciSorgulamaPort } from '../../../auth/adapters/public/kullanici-sorgulama.port';
import { IS_ILANI_SERVICE } from '../../is-ilanlari.tokens';
import { KULLANICI_SORGULAMA_PORT } from '../../../auth/auth.tokens';
import { IsIlaniListeDto } from './is-ilani-liste.dto';
import { IsIlaniOlusturDto } from './is-ilani-olustur.dto';
import { IsBasvurusuDurumGuncelleDto } from './is-basvurusu-durum-guncelle.dto';

@ApiTags('is-ilanlari')
@ApiBearerAuth()
// BİLEREK controller seviyesinde guard YOK — katalog modeli (bkz.
// docs/YENI-MODUL-REHBERI.md "Okuma AÇIK, yazma KORUMALI"). Bir ziyaretçi
// giriş yapmadan iş ilanlarını görebilmeli; guard sadece yazma/kişiye-özel
// metotlarda tek tek yazılı.
@Controller('is-ilanlari')
export class IsIlaniController {
  constructor(
    @Inject(IS_ILANI_SERVICE) private readonly isIlaniService: IsIlaniService,
    @Inject(KULLANICI_SORGULAMA_PORT) private readonly kullaniciSorgulama: KullaniciSorgulamaPort,
    @Inject(FILE_STORAGE_PORT) private readonly fileStorage: FileStoragePort,
  ) {}

  @Get()
  async listele(@Query() filtre: IsIlaniListeDto): Promise<ApiResponseDto<IsIlaniResponse[]>> {
    const ilanlar = await this.isIlaniService.listele(filtre);
    const yanitlar = await Promise.all(ilanlar.map((ilan) => this.yanitaCevir(ilan)));
    return ApiResponseDto.ok(yanitlar);
  }

  /**
   * DİKKAT — SIRA ÖNEMLİ: bu metot `@Get(':id')`'den ÖNCE tanımlı olmak
   * zorunda. NestJS rotaları tanımlanma sırasına göre eşleştirir; ':id' üstte
   * olsaydı `/is-ilanlari/basvurularim` isteği "basvurularim" kelimesini bir
   * id sanıp 404 dönerdi (bkz. firma.controller.ts'teki `sektorler` route'u
   * — aynı tuzak orada da yaşanmıştı).
   */
  @Get('basvurularim')
  @UseGuards(JwtAuthGuard)
  async basvurularim(@AktifKullaniciBilgisi() kullanici: AktifKullanici): Promise<ApiResponseDto<BasvurumResponse[]>> {
    const basvurular = await this.isIlaniService.basvurularim(kullanici.id);
    const yanitlar = await Promise.all(basvurular.map((basvuru) => this.basvurumYanitinaCevir(basvuru)));
    return ApiResponseDto.ok(yanitlar);
  }

  @Get(':id')
  async detay(@Param('id') id: string): Promise<ApiResponseDto<IsIlaniResponse>> {
    try {
      const ilan = await this.isIlaniService.detay(id);
      return ApiResponseDto.ok(await this.yanitaCevir(ilan));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  @Post()
  @UseGuards(YetkiGuard)
  @Yetki(YETKILER.IS_ILANI_YONET)
  async olustur(
    @Body() dto: IsIlaniOlusturDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<IsIlaniResponse>> {
    const firmaId = this.firmaIdZorunluGetir(kullanici);
    try {
      const ilan = await this.isIlaniService.olustur(firmaId, kullanici.id, dto);
      return ApiResponseDto.ok(await this.yanitaCevir(ilan));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  @Put(':id/kapat')
  @UseGuards(YetkiGuard)
  @Yetki(YETKILER.IS_ILANI_YONET)
  async kapat(
    @Param('id') id: string,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<IsIlaniResponse>> {
    const firmaId = this.firmaIdZorunluGetir(kullanici);
    try {
      const ilan = await this.isIlaniService.kapat(id, firmaId);
      return ApiResponseDto.ok(await this.yanitaCevir(ilan));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  @Get(':id/basvurular')
  @UseGuards(YetkiGuard)
  @Yetki(YETKILER.IS_ILANI_YONET)
  async basvurulariGetir(
    @Param('id') id: string,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<IsBasvurusuResponse[]>> {
    const firmaId = this.firmaIdZorunluGetir(kullanici);
    try {
      const basvurular = await this.isIlaniService.basvurulariGetir(id, firmaId);
      const yanitlar = await Promise.all(basvurular.map((basvuru) => this.basvuruYanitinaCevir(basvuru)));
      return ApiResponseDto.ok(yanitlar);
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  /**
   * `cv` alanı OPSİYONEL — dosya seçmeden de başvurulabilir. Dosya varsa
   * önce FileStoragePort ile diske yazılır, sonra dönen URL başvuruyla
   * birlikte kaydedilir (CookzoneModule'deki bildirim port'u gibi, bu da
   * FileStorageModule @Global olduğu için burada ayrıca import edilmiyor).
   */
  @Post(':id/basvur')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(FileInterceptor('cv'))
  async basvur(
    @Param('id') id: string,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
    @UploadedFile() cv?: Express.Multer.File,
  ): Promise<ApiResponseDto<IsBasvurusuResponse>> {
    try {
      const cvUrl = cv ? await this.fileStorage.upload(cv.originalname, cv.buffer) : null;
      const basvuru = await this.isIlaniService.basvur(id, kullanici.id, cvUrl);
      return ApiResponseDto.ok(await this.basvuruYanitinaCevir(basvuru));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  @Put(':id/basvurular/:basvuruId/durum')
  @UseGuards(YetkiGuard)
  @Yetki(YETKILER.IS_ILANI_YONET)
  async basvuruDurumGuncelle(
    @Param('id') id: string,
    @Param('basvuruId') basvuruId: string,
    @Body() dto: IsBasvurusuDurumGuncelleDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<IsBasvurusuResponse>> {
    const firmaId = this.firmaIdZorunluGetir(kullanici);
    try {
      const basvuru = await this.isIlaniService.basvuruDurumGuncelle(id, basvuruId, firmaId, dto);
      return ApiResponseDto.ok(await this.basvuruYanitinaCevir(basvuru));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  /**
   * Firma yetkilisi rolündeki bir hesabın `firmaId`si olmaması, veri
   * tutarsızlığı demektir (admin firmaya bağlamadan bu rolü vermiş olmalı) —
   * sessizce geçmek yerine burada net bir hata ile durduruyoruz.
   */
  private firmaIdZorunluGetir(kullanici: AktifKullanici): string {
    if (!kullanici.firmaId) {
      throw new BadRequestException('Hesabınıza bağlı bir firma bulunmuyor');
    }
    return kullanici.firmaId;
  }

  private httpHatasinaCevir(hata: unknown): unknown {
    if (hata instanceof IsIlaniBulunamadiException) {
      return new NotFoundException(hata.message);
    }
    if (hata instanceof FirmaOnayliDegilException) {
      return new BadRequestException(hata.message);
    }
    if (hata instanceof BaskaFirmayaAitException) {
      return new ForbiddenException(hata.message);
    }
    if (hata instanceof ZatenBasvurulduException) {
      return new BadRequestException(hata.message);
    }
    if (hata instanceof IlanKapaliException) {
      return new BadRequestException(hata.message);
    }
    if (hata instanceof BasvuruBulunamadiException) {
      return new NotFoundException(hata.message);
    }
    return hata;
  }

  private async yanitaCevir(ilan: IsIlani): Promise<IsIlaniResponse> {
    const [firmaAdi, favoriSayisi, basvuruSayisi] = await Promise.all([
      this.isIlaniService.firmaAdi(ilan.firmaId),
      this.isIlaniService.favoriSayisi(ilan.id),
      this.isIlaniService.basvuruSayisi(ilan.id),
    ]);
    return {
      id: ilan.id,
      firmaId: ilan.firmaId,
      firmaAdi: firmaAdi ?? 'Bilinmeyen Firma',
      baslik: ilan.baslik,
      aciklama: ilan.aciklama,
      konum: ilan.konum,
      yayinTarihi: ilan.yayinTarihi.toISOString(),
      durum: ilan.durum,
      favoriSayisi,
      basvuruSayisi,
    };
  }

  private async basvuruYanitinaCevir(basvuru: IsBasvurusu): Promise<IsBasvurusuResponse> {
    const adSoyad = await this.kullaniciSorgulama.adSoyadGetir(basvuru.kullaniciId);
    return {
      id: basvuru.id,
      isIlaniId: basvuru.isIlaniId,
      kullaniciId: basvuru.kullaniciId,
      kullaniciAdSoyad: adSoyad ?? 'Bilinmeyen Kullanıcı',
      basvuruTarihi: basvuru.basvuruTarihi.toISOString(),
      durum: basvuru.durum,
      cvUrl: basvuru.cvUrl,
    };
  }

  /**
   * `isIlaniService.detay()` çağırıyor — başvuru var olduğu sürece ilan da
   * var olmak zorunda (FK: `is_basvurusu.is_ilani_id`, ilan silinmeden önce
   * bağlı başvurular silinmeli, bkz. seed.ts'teki aynı kısıt), yani burada
   * `IsIlaniBulunamadiException` fırlamaz.
   */
  private async basvurumYanitinaCevir(basvuru: IsBasvurusu): Promise<BasvurumResponse> {
    const ilan = await this.isIlaniService.detay(basvuru.isIlaniId);
    const firmaAdi = await this.isIlaniService.firmaAdi(ilan.firmaId);
    return {
      id: basvuru.id,
      isIlaniId: basvuru.isIlaniId,
      isIlaniBasligi: ilan.baslik,
      firmaAdi: firmaAdi ?? 'Bilinmeyen Firma',
      basvuruTarihi: basvuru.basvuruTarihi.toISOString(),
      durum: basvuru.durum,
      cvUrl: basvuru.cvUrl,
    };
  }
}
