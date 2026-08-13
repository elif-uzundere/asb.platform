import { Type } from 'class-transformer';
import { ArrayMinSize, IsArray, IsDateString, IsInt, IsString, Min, ValidateNested } from 'class-validator';
import type { CookzoneSiparisKalemiRequest, CookzoneSiparisOlusturRequest } from '@asb/shared-types';

export class CookzoneSiparisKalemiDto implements CookzoneSiparisKalemiRequest {
  @IsString({ message: 'Menü öğesi geçersiz' })
  menuOgesiId!: string;

  @IsInt({ message: 'Adet tam sayı olmalı' })
  @Min(1, { message: 'Adet en az 1 olmalı' })
  adet!: number;
}

export class CookzoneSiparisOlusturDto implements CookzoneSiparisOlusturRequest {
  @IsString({ message: 'İşletme geçersiz' })
  isletmeId!: string;

  @IsDateString({}, { message: 'Alınma saati geçerli bir tarih/saat olmalı' })
  alinmaSaati!: string;

  @IsArray({ message: 'Sepet listesi geçersiz' })
  @ArrayMinSize(1, { message: 'Sepetinizde en az bir ürün olmalı' })
  @ValidateNested({ each: true })
  @Type(() => CookzoneSiparisKalemiDto)
  kalemler!: CookzoneSiparisKalemiDto[];
}
