import { IsBoolean, IsEmail, IsOptional, IsString } from 'class-validator';
import type { LoginRequest } from '@asb/shared-types';

// Mesajlar Türkçe — bkz. register.dto.ts'teki not.
export class LoginDto implements LoginRequest {
  @IsEmail({}, { message: 'Geçerli bir e-posta adresi girin' })
  email!: string;

  @IsString({ message: 'Şifre geçersiz' })
  sifre!: string;

  @IsOptional()
  @IsBoolean({ message: '"Beni hatırla" değeri geçersiz' })
  beniHatirla?: boolean;
}
