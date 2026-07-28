import { IsEmail, IsOptional, IsString, Matches, MinLength } from 'class-validator';
import type { RegisterRequest } from '@asb/shared-types';

// Not: mesajlar Türkçe ve doğrudan kullanıcıya gösterilebilir olmalı —
// istemci (Flutter) `error.message`'ı kod→metin eşlemesi yapmadan gösteriyor.
export class RegisterDto implements RegisterRequest {
  @IsString({ message: 'Ad geçersiz' })
  ad!: string;

  @IsString({ message: 'Soyad geçersiz' })
  soyad!: string;

  @IsEmail({}, { message: 'Geçerli bir e-posta adresi girin' })
  email!: string;

  @IsString({ message: 'Şifre geçersiz' })
  @MinLength(8, { message: 'Şifre en az 8 karakter olmalı' })
  @Matches(/\d/, { message: 'Şifre en az 1 rakam içermeli' })
  sifre!: string;

  @IsOptional()
  @IsString({ message: 'Telefon geçersiz' })
  telefon?: string;
}
