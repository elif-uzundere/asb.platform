import { IsString, MaxLength, MinLength } from 'class-validator';
import type { DestekTalebiOlusturRequest } from '@asb/shared-types';

export class DestekTalebiOlusturDto implements DestekTalebiOlusturRequest {
  @IsString({ message: 'Başlık geçersiz' })
  @MinLength(3, { message: 'Başlık en az 3 karakter olmalı' })
  @MaxLength(150, { message: 'Başlık en fazla 150 karakter olabilir' })
  baslik!: string;

  @IsString({ message: 'Açıklama geçersiz' })
  @MinLength(10, { message: 'Açıklama en az 10 karakter olmalı' })
  aciklama!: string;
}
