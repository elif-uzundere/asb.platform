import { IsIn, IsString } from 'class-validator';
import type { CihazPlatformu, CihazTokeniKaydetRequest } from '@asb/shared-types';

const PLATFORMLAR: CihazPlatformu[] = ['android', 'ios', 'web'];

export class CihazTokeniKaydetDto implements CihazTokeniKaydetRequest {
  @IsString({ message: 'Token geçersiz' })
  token!: string;

  @IsIn(PLATFORMLAR, { message: 'Platform geçersiz' })
  platform!: CihazPlatformu;
}
