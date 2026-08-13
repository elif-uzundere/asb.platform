import { IsIn } from 'class-validator';
import type { IsBasvurusuDurumGuncelleRequest } from '@asb/shared-types';

export class IsBasvurusuDurumGuncelleDto implements IsBasvurusuDurumGuncelleRequest {
  @IsIn(['incelendi', 'reddedildi', 'kabul'], { message: 'Geçersiz başvuru durumu' })
  durum!: 'incelendi' | 'reddedildi' | 'kabul';
}
