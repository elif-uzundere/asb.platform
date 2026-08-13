import { BadRequestException, Body, Controller, ForbiddenException, Get, Inject, NotFoundException, Param, Post, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type {
  CookzoneIsletmeResponse,
  CookzoneSiparisResponse,
  CookzoneSiparisYonetimResponse,
} from '@asb/shared-types';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { JwtAuthGuard } from '../../../../shared/web/jwt-auth.guard';
import { Roller } from '../../../../shared/web/roller.decorator';
import { RollerGuard } from '../../../../shared/web/roller.guard';
import { AktifKullaniciBilgisi } from '../../../../shared/web/aktif-kullanici.decorator';
import type { AktifKullanici } from '../../../../shared/web/jwt-icerigi';
import type { CookzoneService } from '../../application';
import {
  CookzoneIsletme,
  CookzoneSiparis,
  CookzoneSiparisKalemi,
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
    if (hata instanceof BaskaIsletmeyeAitException) {
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
      menuOgeleri: menuOgeleri.map((oge) => ({
        id: oge.id,
        ad: oge.ad,
        aciklama: oge.aciklama,
        fiyat: oge.fiyat,
        kategori: oge.kategori,
      })),
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
