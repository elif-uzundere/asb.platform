import { IsOptional, IsString } from 'class-validator';
import type { FirmaListeRequest } from '@asb/shared-types';

export class FirmaListeDto implements FirmaListeRequest {
  @IsOptional()
  @IsString({ message: 'Arama metni geçersiz' })
  arama?: string;

  @IsOptional()
  @IsString({ message: 'Sektör geçersiz' })
  sektor?: string;
}