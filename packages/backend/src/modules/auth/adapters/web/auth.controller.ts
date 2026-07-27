import {
  BadRequestException,
  Body,
  ConflictException,
  Controller,
  Inject,
  Post,
  UnauthorizedException,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import type { LoginResponse } from '@asb/shared-types';
import type { AuthService } from '../../application';
import {
  EmailZatenKayitliException,
  GecersizEmailException,
  GecersizKimlikBilgisiException,
  GecersizSifirlamaTokenException,
} from '../../domain';
import { AUTH_SERVICE } from '../../auth.tokens';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { RegisterDto } from './register.dto';
import { LoginDto } from './login.dto';
import { SifremiUnuttumDto } from './forgot-password.dto';
import { SifreSifirlaDto } from './reset-password.dto';

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

  private httpHatayaCevir(hata: unknown): Error {
    if (hata instanceof EmailZatenKayitliException) return new ConflictException(hata.message);
    if (hata instanceof GecersizKimlikBilgisiException) return new UnauthorizedException(hata.message);
    if (hata instanceof GecersizEmailException) return new BadRequestException(hata.message);
    if (hata instanceof GecersizSifirlamaTokenException) return new BadRequestException(hata.message);
    return hata instanceof Error ? hata : new Error('Bilinmeyen hata');
  }
}