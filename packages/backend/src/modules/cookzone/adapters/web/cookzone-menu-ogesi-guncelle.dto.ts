import { Transform, Type } from 'class-transformer';
import { IsBoolean, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class CookzoneMenuOgesiGuncelleDto {
  @IsOptional()
  @IsString({ message: 'Ad metin olmalıdır' })
  ad?: string;

  @IsOptional()
  @IsString({ message: 'Açıklama metin olmalıdır' })
  aciklama?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber({}, { message: 'Fiyat sayısal bir değer olmalıdır' })
  @Min(0, { message: 'Fiyat negatif olamaz' })
  fiyat?: number;

  @IsOptional()
  @IsString({ message: 'Kategori metin olmalıdır' })
  kategori?: string;

  // multipart/form-data gövdesinde boolean her zaman string gelir
  // ("true"/"false") — class-transformer'ın varsayılan Boolean() dönüşümü
  // her non-empty string'i true sayar (`Boolean('false') === true`), bu
  // yüzden elle karşılaştırma gerekiyor.
  @IsOptional()
  @Transform(({ value }) => (typeof value === 'string' ? value === 'true' : value))
  @IsBoolean({ message: 'Aktiflik değeri geçersiz' })
  aktif?: boolean;
}
