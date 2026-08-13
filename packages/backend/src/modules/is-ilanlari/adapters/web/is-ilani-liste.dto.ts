import { IsOptional, IsString } from 'class-validator';
import type { IsIlaniListeRequest } from '@asb/shared-types';

export class IsIlaniListeDto implements IsIlaniListeRequest {
  @IsOptional()
  @IsString({ message: 'Konum geçersiz' })
  konum?: string;

  @IsOptional()
  @IsString({ message: 'Firma id geçersiz' })
  firmaId?: string;
}
