import { IsDateString, IsInt, IsOptional, IsString, IsUrl, Min, MaxLength, MinLength } from 'class-validator';
import type { FirmaOlusturRequest } from '@asb/shared-types';

// Mesajlar Türkçe — global ValidationPipe açık ve Flutter `error.message`'ı
// kullanıcıya olduğu gibi gösteriyor (mimari kural 7).
// Uzunluk sınırları schema.prisma'daki VarChar boylarıyla hizalı; aksi halde
// istek doğrulamayı geçip veritabanında patlardı.
export class FirmaOlusturDto implements FirmaOlusturRequest {
  @IsString({ message: 'Firma adı geçersiz' })
  @MinLength(2, { message: 'Firma adı en az 2 karakter olmalı' })
  @MaxLength(150, { message: 'Firma adı en fazla 150 karakter olabilir' })
  ad!: string;

  @IsString({ message: 'Sektör geçersiz' })
  @MinLength(2, { message: 'Sektör en az 2 karakter olmalı' })
  @MaxLength(80, { message: 'Sektör en fazla 80 karakter olabilir' })
  sektor!: string;

  @IsString({ message: 'Adres geçersiz' })
  @MinLength(5, { message: 'Adres en az 5 karakter olmalı' })
  @MaxLength(255, { message: 'Adres en fazla 255 karakter olabilir' })
  adres!: string;

  @IsOptional()
  @IsUrl({}, { message: 'Logo adresi geçerli bir URL olmalı' })
  @MaxLength(255, { message: 'Logo adresi en fazla 255 karakter olabilir' })
  logoUrl?: string;

  @IsOptional()
  @IsString({ message: 'Telefon geçersiz' })
  @MaxLength(20, { message: 'Telefon en fazla 20 karakter olabilir' })
  telefon?: string;

  @IsOptional()
  @IsString({ message: 'E-posta geçersiz' })
  @MaxLength(150, { message: 'E-posta en fazla 150 karakter olabilir' })
  eposta?: string;

  @IsOptional()
  @IsUrl({}, { message: 'Web adresi geçerli bir URL olmalı' })
  @MaxLength(255, { message: 'Web adresi en fazla 255 karakter olabilir' })
  webAdres?: string;

  @IsOptional()
  @IsDateString({}, { message: 'Kuruluş tarihi geçerli bir tarih olmalı (YYYY-AA-GG)' })
  kurulusTarihi?: string;

  @IsOptional()
  @IsInt({ message: 'Personel sayısı tam sayı olmalı' })
  @Min(0, { message: 'Personel sayısı negatif olamaz' })
  personelSayisi?: number;
}
