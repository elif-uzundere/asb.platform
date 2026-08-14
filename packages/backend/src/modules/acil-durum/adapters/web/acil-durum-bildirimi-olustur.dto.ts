import { IsIn, IsString, MinLength } from 'class-validator';
import type { AcilDurumBildirimiOlusturRequest } from '@asb/shared-types';

export class AcilDurumBildirimiOlusturDto implements AcilDurumBildirimiOlusturRequest {
  @IsIn(['yangin', 'kaza', 'saglik', 'diger'], { message: 'Geçersiz acil durum türü' })
  tur!: 'yangin' | 'kaza' | 'saglik' | 'diger';

  @IsString({ message: 'Açıklama geçersiz' })
  @MinLength(1, { message: 'Bildirim için açıklama girmelisiniz' })
  aciklama!: string;
}
