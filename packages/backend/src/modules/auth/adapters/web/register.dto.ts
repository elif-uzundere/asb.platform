import { IsEmail, IsOptional, IsString, Matches, MinLength } from 'class-validator';
import type { RegisterRequest } from '@asb/shared-types';

export class RegisterDto implements RegisterRequest {
  @IsString()
  ad!: string;

  @IsString()
  soyad!: string;

  @IsEmail()
  email!: string;

  @MinLength(8, { message: 'Şifre en az 8 karakter olmalı' })
  @Matches(/\d/, { message: 'Şifre en az 1 rakam içermeli' })
  sifre!: string;

  @IsOptional()
  @IsString()
  telefon?: string;
}