import { IsEmail, IsString } from 'class-validator';
import type { EpostaDegistirRequest } from '@asb/shared-types';

export class EpostaDegistirDto implements EpostaDegistirRequest {
  @IsEmail({}, { message: 'Geçerli bir e-posta adresi girin' })
  yeniEposta!: string;

  @IsString({ message: 'Mevcut şifre geçersiz' })
  mevcutSifre!: string;
}
