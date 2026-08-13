import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import type { PaletOlusturRequest } from '@asb/shared-types';

// Uzunluk sınırları schema.prisma'daki VarChar boylarıyla hizalı (mimari kural 7).
// `multipart/form-data` gövdesinin metin alanları — `gorsel` dosyası ayrı
// (@UploadedFile), bu DTO'nun parçası değil.
export class PaletOlusturDto implements PaletOlusturRequest {
  @IsString({ message: 'Ad geçersiz' })
  @MinLength(2, { message: 'Ad en az 2 karakter olmalı' })
  @MaxLength(120, { message: 'Ad en fazla 120 karakter olabilir' })
  ad!: string;

  @IsOptional()
  @IsString({ message: 'Açıklama geçersiz' })
  aciklama?: string;

  @IsOptional()
  @IsString({ message: 'Ölçü geçersiz' })
  @MaxLength(80, { message: 'Ölçü en fazla 80 karakter olabilir' })
  olcu?: string;
}
