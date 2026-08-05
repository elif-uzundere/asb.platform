import { IsOptional, IsString } from 'class-validator';
import type { ProfilGuncelleRequest } from '@asb/shared-types';

export class ProfilGuncelleDto implements ProfilGuncelleRequest {
  @IsString({ message: 'Ad geçersiz' })
  ad!: string;

  @IsString({ message: 'Soyad geçersiz' })
  soyad!: string;

  @IsOptional()
  @IsString({ message: 'Telefon geçersiz' })
  telefon?: string;
}
