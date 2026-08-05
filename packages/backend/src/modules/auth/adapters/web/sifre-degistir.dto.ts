import { IsString, Matches, MinLength } from 'class-validator';
import type { SifreDegistirRequest } from '@asb/shared-types';

export class SifreDegistirDto implements SifreDegistirRequest {
  @IsString({ message: 'Mevcut şifre geçersiz' })
  mevcutSifre!: string;

  @IsString({ message: 'Şifre geçersiz' })
  @MinLength(8, { message: 'Şifre en az 8 karakter olmalı' })
  @Matches(/\d/, { message: 'Şifre en az 1 rakam içermeli' })
  yeniSifre!: string;
}
