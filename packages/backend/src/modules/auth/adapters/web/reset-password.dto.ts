import { IsString, Matches, MinLength } from 'class-validator';
import type { SifreSifirlaRequest } from '@asb/shared-types';

// Mesajlar Türkçe — bkz. register.dto.ts'teki not.
export class SifreSifirlaDto implements SifreSifirlaRequest {
  // Token e-postadaki linkten gelir; kullanıcı elle girmediği için mesajı
  // "link geçersiz" diliyle veriyoruz.
  @IsString({ message: 'Sıfırlama linki geçersiz' })
  token!: string;

  @IsString({ message: 'Şifre geçersiz' })
  @MinLength(8, { message: 'Şifre en az 8 karakter olmalı' })
  @Matches(/\d/, { message: 'Şifre en az 1 rakam içermeli' })
  yeniSifre!: string;
}
