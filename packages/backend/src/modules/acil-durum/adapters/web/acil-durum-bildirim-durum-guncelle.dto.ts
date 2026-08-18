import { IsIn } from 'class-validator';
import type { AcilDurumBildirimDurumGuncelleRequest } from '@asb/shared-types';

export class AcilDurumBildirimDurumGuncelleDto implements AcilDurumBildirimDurumGuncelleRequest {
  @IsIn(['inceleniyor', 'kapatildi'], { message: 'Geçersiz bildirim durumu' })
  durum!: 'inceleniyor' | 'kapatildi';
}
