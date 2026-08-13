import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import type { IsIlaniOlusturRequest } from '@asb/shared-types';

// Uzunluk sınırları schema.prisma'daki VarChar boylarıyla hizalı (mimari kural 7).
export class IsIlaniOlusturDto implements IsIlaniOlusturRequest {
  @IsString({ message: 'Başlık geçersiz' })
  @MinLength(3, { message: 'Başlık en az 3 karakter olmalı' })
  @MaxLength(150, { message: 'Başlık en fazla 150 karakter olabilir' })
  baslik!: string;

  @IsString({ message: 'Açıklama geçersiz' })
  @MinLength(10, { message: 'Açıklama en az 10 karakter olmalı' })
  aciklama!: string;

  @IsOptional()
  @IsString({ message: 'Konum geçersiz' })
  @MaxLength(150, { message: 'Konum en fazla 150 karakter olabilir' })
  konum?: string;
}
