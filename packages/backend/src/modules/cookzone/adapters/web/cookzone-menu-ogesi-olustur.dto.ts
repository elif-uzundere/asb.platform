import { Type } from 'class-transformer';
import { IsNotEmpty, IsNumber, IsOptional, IsString, Min } from 'class-validator';

// `multipart/form-data` gövdesinin metin alanları — `gorsel` dosyası ayrı
// (@UploadedFile), palet-olustur.dto.ts'teki aynı desen.
export class CookzoneMenuOgesiOlusturDto {
  @IsString({ message: 'Ad metin olmalıdır' })
  @IsNotEmpty({ message: 'Ad boş bırakılamaz' })
  ad!: string;

  @IsOptional()
  @IsString({ message: 'Açıklama metin olmalıdır' })
  aciklama?: string;

  @Type(() => Number)
  @IsNumber({}, { message: 'Fiyat sayısal bir değer olmalıdır' })
  @Min(0, { message: 'Fiyat negatif olamaz' })
  fiyat!: number;

  @IsString({ message: 'Kategori metin olmalıdır' })
  @IsNotEmpty({ message: 'Kategori boş bırakılamaz' })
  kategori!: string;
}
