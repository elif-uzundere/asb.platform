import { IsISO8601, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class DuyuruOlusturDto {
  @ApiProperty({
    example: 'Sistem Bakım Duyurusu',
    description: 'Duyurunun başlığı',
  })
  @IsString({ message: 'Başlık metin olmalı.' })
  @MinLength(3, { message: 'Başlık en az 3 karakter olmalı.' })
  @MaxLength(200, { message: 'Başlık en fazla 200 karakter olabilir.' })
  baslik!: string;

  @ApiProperty({
    example: 'Sistem pazar günü bakım nedeniyle kullanılamayacaktır.',
    description: 'Duyurunun ayrıntılı içeriği',
  })
  @IsString({ message: 'İçerik metin olmalı.' })
  @MinLength(5, { message: 'İçerik en az 5 karakter olmalı.' })
  icerik!: string;

  @ApiPropertyOptional({
    example: 'Genel',
    description: 'Duyurunun kategorisi',
  })
  @IsOptional()
  @IsString({ message: 'Kategori metin olmalı.' })
  @MaxLength(60, { message: 'Kategori en fazla 60 karakter olabilir.' })
  kategori?: string;

  @ApiPropertyOptional({
    example: '2026-08-03T09:00:00.000Z',
    description: 'Duyurunun yayın tarihi. Gönderilmezse mevcut tarih kullanılır.',
  })
  @IsOptional()
  @IsISO8601({}, { message: 'Yayın tarihi ISO 8601 biçiminde olmalı.' })
  yayinTarihi?: string;
}
