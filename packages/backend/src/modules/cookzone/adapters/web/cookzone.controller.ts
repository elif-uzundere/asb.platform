import {
  BadRequestException,
  Body,
  Controller,
  Delete,
  FileTypeValidator,
  ForbiddenException,
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
import type {
  CookzoneIsletmeResponse,
  CookzoneMenuOgesiResponse,
  CookzoneSiparisResponse,
  CookzoneSiparisYonetimResponse,
} from '@asb/shared-types';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { JwtAuthGuard } from '../../../../shared/web/jwt-auth.guard';
import { Roller } from '../../../../shared/web/roller.decorator';
import { RollerGuard } from '../../../../shared/web/roller.guard';
import { AktifKullaniciBilgisi } from '../../../../shared/web/aktif-kullanici.decorator';
import type { AktifKullanici } from '../../../../shared/web/jwt-icerigi';
import { FILE_STORAGE_PORT, FileStoragePort } from '../../../../shared/infrastructure/file-storage/file-storage.port';
import type { CookzoneService } from '../../application';
import {
  CookzoneIsletme,
  CookzoneMenuOgesi,
  CookzoneSiparis,
  CookzoneSiparisKalemi,
  BaskaIsletmeninMenuOgesiException,
  CookzoneIsletmeBulunamadiException,
  CookzoneMenuOgesiBulunamadiException,
  CookzoneSiparisBulunamadiException,
  BaskaIsletmeyeAitException,
  BosSepetIleSiparisVerilemezException,
  GecmisSaateSiparisVerilemezException,
  SiparisIlerletilemezException,
} from '../../domain';
import type { BolgeNoktasiSorgulamaPort } from '../../../harita/adapters/public/bolge-noktasi-sorgulama.port';
import type { KullaniciSorgulamaPort } from '../../../auth/adapters/public/kullanici-sorgulama.port';
import { COOKZONE_SERVICE } from '../../cookzone.tokens';
import { BOLGE_NOKTASI_SORGULAMA_PORT } from '../../../harita/harita.tokens';
import { KULLANICI_SORGULAMA_PORT } from '../../../auth/auth.tokens';
import { CookzoneSiparisOlusturDto } from './cookzone-siparis-olustur.dto';
import { CookzoneMenuOgesiOlusturDto } from './cookzone-menu-ogesi-olustur.dto';
import { CookzoneMenuOgesiGuncelleDto } from './cookzone-menu-ogesi-guncelle.dto';

const GORSEL_DOGRULAMA = new ParseFilePipe({
  validators: [
    new MaxFileSizeValidator({ maxSize: 5 * 1024 * 1024, message: 'Görsel en fazla 5 MB olabilir' }),
    new FileTypeValidator({ fileType: /^image\/(jpeg|png|webp)$/ }),
  ],
  fileIsRequired: false,
});

@ApiTags('cookzone')
@ApiBearerAuth()
// BİLEREK controller seviyesinde guard YOK — katalog modeli: menü herkese
// açık görünür olmalı (bkz. docs/YENI-MODUL-REHBERI.md). Sadece sipariş
// verme/yönetme kişiye özel, tek tek işaretli.
@Controller('cookzone')
export class CookzoneController {
  constructor(
    @Inject(COOKZONE_SERVICE) private readonly cookzoneService: CookzoneService,
    @Inject(BOLGE_NOKTASI_SORGULAMA_PORT) private readonly bolgeNoktasiSorgulama: BolgeNoktasiSorgulamaPort,
    @Inject(KULLANICI_SORGULAMA_PORT) private readonly kullaniciSorgulama: KullaniciSorgulamaPort,
    @Inject(FILE_STORAGE_PORT) private readonly fileStorage: FileStoragePort,
  ) {}

  @Get('isletmeler')
  async isletmeler(): Promise<ApiResponseDto<CookzoneIsletmeResponse[]>> {
    const isletmeler = await this.cookzoneService.isletmeler();
    const yanitlar = await Promise.all(isletmeler.map((isletme) => this.isletmeYanitinaCevir(isletme)));
    return ApiResponseDto.ok(yanitlar);
  }

  @Get('isletmeler/:id')
  async isletmeDetay(@Param('id') id: string): Promise<ApiResponseDto<CookzoneIsletmeResponse>> {
    try {
      const isletme = await this.cookzoneService.isletmeDetay(id);
      return ApiResponseDto.ok(await this.isletmeYanitinaCevir(isletme));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  @Post('siparisler')
  @UseGuards(JwtAuthGuard)
  async siparisOlustur(
    @Body() dto: CookzoneSiparisOlusturDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<CookzoneSiparisResponse>> {
    try {
      const siparis = await this.cookzoneService.siparisOlustur(
        kullanici.id,
        dto.isletmeId,
        new Date(dto.alinmaSaati),
        dto.kalemler,
      );
      return ApiResponseDto.ok(await this.siparisYanitinaCevir(siparis));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  @Get('siparislerim')
  @UseGuards(JwtAuthGuard)
  async siparislerim(
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<CookzoneSiparisResponse[]>> {
    const siparisler = await this.cookzoneService.siparislerim(kullanici.id);
    const yanitlar = await Promise.all(siparisler.map((siparis) => this.siparisYanitinaCevir(siparis)));
    return ApiResponseDto.ok(yanitlar);
  }

  @Get('siparisler')
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller('cookzone_yetkilisi')
  async isletmeSiparisleri(
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<CookzoneSiparisYonetimResponse[]>> {
    const isletmeId = this.isletmeIdZorunluGetir(kullanici);
    const siparisler = await this.cookzoneService.isletmeSiparisleri(isletmeId);
    const yanitlar = await Promise.all(siparisler.map((siparis) => this.yonetimYanitinaCevir(siparis)));
    return ApiResponseDto.ok(yanitlar);
  }

  @Put('siparisler/:id/ilerlet')
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller('cookzone_yetkilisi')
  async siparisIlerlet(
    @Param('id') id: string,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<CookzoneSiparisYonetimResponse>> {
    const isletmeId = this.isletmeIdZorunluGetir(kullanici);
    try {
      const siparis = await this.cookzoneService.siparisIlerlet(id, isletmeId);
      return ApiResponseDto.ok(await this.yonetimYanitinaCevir(siparis));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  // ── Menü yönetimi — cookzone_yetkilisi tarafı ───────────────────────────

  /**
   * `/menu/:id`'den ÖNCE değil, bilerek `/menu` altında farklı bir literal
   * segment — is-ilanlari.controller.ts'teki aynı sıra kuralına uyuluyor.
   */
  @Get('menu/tumu')
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller('cookzone_yetkilisi')
  async menuOgeleriTumunuGetir(
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<CookzoneMenuOgesiResponse[]>> {
    const isletmeId = this.isletmeIdZorunluGetir(kullanici);
    const menuOgeleri = await this.cookzoneService.menuOgeleriTumunuGetir(isletmeId);
    return ApiResponseDto.ok(menuOgeleri.map((oge) => this.menuOgesiYanitinaCevir(oge)));
  }

  @Post('menu')
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller('cookzone_yetkilisi')
  @UseInterceptors(FileInterceptor('gorsel'))
  async menuOgesiOlustur(
    @Body() dto: CookzoneMenuOgesiOlusturDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
    @UploadedFile(GORSEL_DOGRULAMA) gorsel?: Express.Multer.File,
  ): Promise<ApiResponseDto<CookzoneMenuOgesiResponse>> {
    const isletmeId = this.isletmeIdZorunluGetir(kullanici);
    const gorselUrl = gorsel ? await this.fileStorage.upload(gorsel.originalname, gorsel.buffer) : null;
    const menuOgesi = await this.cookzoneService.menuOgesiOlustur({
      isletmeId,
      ad: dto.ad,
      aciklama: dto.aciklama ?? null,
      fiyat: dto.fiyat,
      kategori: dto.kategori,
      gorselUrl,
    });
    return ApiResponseDto.ok(this.menuOgesiYanitinaCevir(menuOgesi));
  }

  @Put('menu/:id')
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller('cookzone_yetkilisi')
  @UseInterceptors(FileInterceptor('gorsel'))
  async menuOgesiGuncelle(
    @Param('id') id: string,
    @Body() dto: CookzoneMenuOgesiGuncelleDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
    @UploadedFile(GORSEL_DOGRULAMA) gorsel?: Express.Multer.File,
  ): Promise<ApiResponseDto<CookzoneMenuOgesiResponse>> {
    const isletmeId = this.isletmeIdZorunluGetir(kullanici);
    try {
      const gorselUrl = gorsel ? await this.fileStorage.upload(gorsel.originalname, gorsel.buffer) : undefined;
      const menuOgesi = await this.cookzoneService.menuOgesiGuncelle(id, isletmeId, {
        ad: dto.ad,
        aciklama: dto.aciklama,
        fiyat: dto.fiyat,
        kategori: dto.kategori,
        aktif: dto.aktif,
        ...(gorselUrl !== undefined ? { gorselUrl } : {}),
      });
      return ApiResponseDto.ok(this.menuOgesiYanitinaCevir(menuOgesi));
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  @Delete('menu/:id')
  @UseGuards(JwtAuthGuard, RollerGuard)
  @Roller('cookzone_yetkilisi')
  async menuOgesiSil(
    @Param('id') id: string,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<null>> {
    const isletmeId = this.isletmeIdZorunluGetir(kullanici);
    try {
      await this.cookzoneService.menuOgesiSil(id, isletmeId);
      return ApiResponseDto.ok(null);
    } catch (hata) {
      throw this.httpHatasinaCevir(hata);
    }
  }

  /**
   * `cookzone_yetkilisi` rolündeki bir hesabın `cookzoneIsletmeId`si olmaması
   * veri tutarsızlığı demektir — is-ilanlari'ndaki `firmaIdZorunluGetir` ile
   * aynı desen/gerekçe.
   */
  private isletmeIdZorunluGetir(kullanici: AktifKullanici): string {
    if (!kullanici.cookzoneIsletmeId) {
      throw new BadRequestException('Hesabınıza bağlı bir işletme bulunmuyor');
    }
    return kullanici.cookzoneIsletmeId;
  }

  private httpHatasinaCevir(hata: unknown): unknown {
    if (
      hata instanceof CookzoneIsletmeBulunamadiException ||
      hata instanceof CookzoneMenuOgesiBulunamadiException ||
      hata instanceof CookzoneSiparisBulunamadiException
    ) {
      return new NotFoundException(hata.message);
    }
    if (hata instanceof BaskaIsletmeyeAitException || hata instanceof BaskaIsletmeninMenuOgesiException) {
      return new ForbiddenException(hata.message);
    }
    if (
      hata instanceof BosSepetIleSiparisVerilemezException ||
      hata instanceof GecmisSaateSiparisVerilemezException ||
      hata instanceof SiparisIlerletilemezException
    ) {
      return new BadRequestException(hata.message);
    }
    return hata;
  }

  private async isletmeYanitinaCevir(isletme: CookzoneIsletme): Promise<CookzoneIsletmeResponse> {
    const [bolgeNoktasiAdi, menuOgeleri] = await Promise.all([
      this.bolgeNoktasiSorgulama.adiGetir(isletme.bolgeNoktasiId),
      this.cookzoneService.menuGetir(isletme.id),
    ]);
    return {
      id: isletme.id,
      ad: isletme.ad,
      bolgeNoktasiAdi: bolgeNoktasiAdi ?? 'Konum belirtilmemiş',
      menuOgeleri: menuOgeleri.map((oge) => this.menuOgesiYanitinaCevir(oge)),
    };
  }

  private menuOgesiYanitinaCevir(oge: CookzoneMenuOgesi): CookzoneMenuOgesiResponse {
    return {
      id: oge.id,
      ad: oge.ad,
      aciklama: oge.aciklama,
      fiyat: oge.fiyat,
      kategori: oge.kategori,
      gorselUrl: oge.gorselUrl,
      aktif: oge.aktif,
    };
  }

  private async siparisYanitinaCevir(siparis: CookzoneSiparis): Promise<CookzoneSiparisResponse> {
    const [isletme, kalemler] = await Promise.all([
      this.cookzoneService.isletmeDetay(siparis.isletmeId),
      this.cookzoneService.siparisKalemleri(siparis.id),
    ]);
    return {
      id: siparis.id,
      isletmeId: siparis.isletmeId,
      isletmeAdi: isletme.ad,
      durum: siparis.durum,
      toplamTutar: siparis.toplamTutar,
      alinmaSaati: siparis.alinmaSaati.toISOString(),
      olusturmaTarihi: siparis.olusturmaTarihi.toISOString(),
      kalemler: this.kalemYanitlarinaCevir(kalemler),
    };
  }

  private async yonetimYanitinaCevir(siparis: CookzoneSiparis): Promise<CookzoneSiparisYonetimResponse> {
    const [adSoyad, kalemler] = await Promise.all([
      this.kullaniciSorgulama.adSoyadGetir(siparis.kullaniciId),
      this.cookzoneService.siparisKalemleri(siparis.id),
    ]);
    return {
      id: siparis.id,
      kullaniciAdSoyad: adSoyad ?? 'Bilinmeyen Kullanıcı',
      durum: siparis.durum,
      toplamTutar: siparis.toplamTutar,
      alinmaSaati: siparis.alinmaSaati.toISOString(),
      olusturmaTarihi: siparis.olusturmaTarihi.toISOString(),
      kalemler: this.kalemYanitlarinaCevir(kalemler),
    };
  }

  private kalemYanitlarinaCevir(kalemler: CookzoneSiparisKalemi[]) {
    return kalemler.map((kalem) => ({
      id: kalem.id,
      menuOgesiAdi: kalem.menuOgesiAdi,
      adet: kalem.adet,
      birimFiyat: kalem.birimFiyat,
    }));
  }
}
