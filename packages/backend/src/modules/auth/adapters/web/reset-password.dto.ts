import { IsString, Matches, MinLength } from 'class-validator';
import type { SifreSifirlaRequest } from '@asb/shared-types';

export class SifreSifirlaDto implements SifreSifirlaRequest {
  @IsString()
  token!: string;

  @MinLength(8, { message: 'Şifre en az 8 karakter olmalı' })
  @Matches(/\d/, { message: 'Şifre en az 1 rakam içermeli' })
  yeniSifre!: string;
}