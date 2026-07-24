import {
  BadRequestException,
  Body,
  ConflictException,
  Controller,
  Inject,
  Post,
  UnauthorizedException,
} from '@nestjs/common';
import { ApiResponseDto } from '../../../../shared/web/api-response.dto';
import { ApiTags } from '@nestjs/swagger';
import type { LoginResponse } from '@asb/shared-types';
import type { AuthService } from '../../application';
import {
  EmailZatenKayitliException,
  GecersizEmailException,
  GecersizKimlikBilgisiException,
} from '../../domain';
import { AUTH_SERVICE } from '../../auth.tokens';
import { RegisterDto } from './register.dto';
import { LoginDto } from './login.dto';

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

  private httpHatayaCevir(hata: unknown): Error {
    if (hata instanceof EmailZatenKayitliException) return new ConflictException(hata.message);
    if (hata instanceof GecersizKimlikBilgisiException) return new UnauthorizedException(hata.message);
    if (hata instanceof GecersizEmailException) return new BadRequestException(hata.message);
    return hata instanceof Error ? hata : new Error('Bilinmeyen hata');
  }
}