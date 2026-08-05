import {
  BadRequestException,
  Body,
  ConflictException,
  Controller,
  Inject,
  Patch,
  Post,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import type { KullaniciOzet, LoginResponse } from '@asb/shared-types';
import type { AuthService } from '../../application';
import {
  EmailZatenKayitliException,
  GecersizEmailException,
  GecersizGoogleTokenException,
  GecersizKimlikBilgisiException,
  GecersizSifirlamaTokenException,
  MevcutSifreYanlisException,
  SifresizHesapException,
} from '../../domain';
import { AUTH_SERVICE } from '../../auth.tokens';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { AktifKullaniciBilgisi } from '../../../../shared/web/aktif-kullanici.decorator';
import { AktifKullanici } from '../../../../shared/web/jwt-icerigi';
import { JwtAuthGuard } from '../../../../shared/web/jwt-auth.guard';
import { RegisterDto } from './register.dto';
import { LoginDto } from './login.dto';
import { SifremiUnuttumDto } from './forgot-password.dto';
import { SifreSifirlaDto } from './reset-password.dto';
import { SifreDegistirDto } from './sifre-degistir.dto';
import { EpostaDegistirDto } from './eposta-degistir.dto';
import { ProfilGuncelleDto } from './profil-guncelle.dto';
import { GoogleGirisDto } from './google-giris.dto';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(@Inject(AUTH_SERVICE) private readonly authService: AuthService) {}

  @Post('register')
  async register(@Body() dto: RegisterDto): Promise<ApiResponseDto<LoginResponse>> {
    try {
      const sonuc = await this.authService.kayitOl(dto);
      return ApiResponseDto.ok(sonuc);
    } catch (hata) {
      throw this.httpHatayaCevir(hata);
    }
  }

  @Post('login')
  async login(@Body() dto: LoginDto): Promise<ApiResponseDto<LoginResponse>> {
    try {
      const sonuc = await this.authService.girisYap(dto);
      return ApiResponseDto.ok(sonuc);
    } catch (hata) {
      throw this.httpHatayaCevir(hata);
    }
  }

  @Post('sifremi-unuttum')
  async sifremiUnuttum(@Body() dto: SifremiUnuttumDto): Promise<ApiResponseDto<null>> {
    await this.authService.sifremiUnuttum(dto);
    return ApiResponseDto.ok(null);
  }

  @Post('sifre-sifirla')
  async sifreSifirla(@Body() dto: SifreSifirlaDto): Promise<ApiResponseDto<null>> {
    try {
      await this.authService.sifreSifirla(dto);
      return ApiResponseDto.ok(null);
    } catch (hata) {
      throw this.httpHatayaCevir(hata);
    }
  }

  @Post('google-giris')
  async googleIleGiris(@Body() dto: GoogleGirisDto): Promise<ApiResponseDto<LoginResponse>> {
    try {
      const sonuc = await this.authService.googleIleGirisYap(dto.idToken);
      return ApiResponseDto.ok(sonuc);
    } catch (hata) {
      throw this.httpHatayaCevir(hata);
    }
  }

  @Patch('sifre-degistir')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async sifreDegistir(
    @Body() dto: SifreDegistirDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<null>> {
    try {
      await this.authService.sifreDegistir(kullanici.id, dto);
      return ApiResponseDto.ok(null);
    } catch (hata) {
      throw this.httpHatayaCevir(hata);
    }
  }

  @Patch('eposta-degistir')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async epostaDegistir(
    @Body() dto: EpostaDegistirDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<null>> {
    try {
      await this.authService.epostaDegistir(kullanici.id, dto);
      return ApiResponseDto.ok(null);
    } catch (hata) {
      throw this.httpHatayaCevir(hata);
    }
  }

  @Patch('profil')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  async profilGuncelle(
    @Body() dto: ProfilGuncelleDto,
    @AktifKullaniciBilgisi() kullanici: AktifKullanici,
  ): Promise<ApiResponseDto<KullaniciOzet>> {
    try {
      const guncellenen = await this.authService.profilGuncelle(kullanici.id, dto);
      return ApiResponseDto.ok(guncellenen);
    } catch (hata) {
      throw this.httpHatayaCevir(hata);
    }
  }

  private httpHatayaCevir(hata: unknown): Error {
    if (hata instanceof EmailZatenKayitliException) return new ConflictException(hata.message);
    if (hata instanceof GecersizKimlikBilgisiException) return new UnauthorizedException(hata.message);
    if (hata instanceof GecersizEmailException) return new BadRequestException(hata.message);
    if (hata instanceof GecersizSifirlamaTokenException) return new BadRequestException(hata.message);
    if (hata instanceof MevcutSifreYanlisException) return new UnauthorizedException(hata.message);
    if (hata instanceof SifresizHesapException) return new BadRequestException(hata.message);
    if (hata instanceof GecersizGoogleTokenException) return new UnauthorizedException(hata.message);
    return hata instanceof Error ? hata : new Error('Bilinmeyen hata');
  }
}