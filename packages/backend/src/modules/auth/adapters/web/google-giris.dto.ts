import { IsString } from 'class-validator';
import type { GoogleGirisRequest } from '@asb/shared-types';

export class GoogleGirisDto implements GoogleGirisRequest {
  @IsString({ message: 'Google token geçersiz' })
  idToken!: string;
}
