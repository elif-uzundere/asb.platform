import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';
import type { PaletGuncelleRequest } from '@asb/shared-types';

/** Kısmi güncelleme — mevcut bir palet çeşidine (örn. seed'den gelen, hiç
 * görseli olmayan bir kayıt) sonradan görsel eklemek için de bu uç kullanılır,
 * o yüzden `ad` bile opsiyonel (sadece görsel eklemek isteyen alanları
 * boş bırakabilmeli). */
export class PaletGuncelleDto implements PaletGuncelleRequest {
  @IsOptional()
  @IsString({ message: 'Ad geçersiz' })
  @MinLength(2, { message: 'Ad en az 2 karakter olmalı' })
  @MaxLength(120, { message: 'Ad en fazla 120 karakter olabilir' })
  ad?: string;

  @IsOptional()
  @IsString({ message: 'Açıklama geçersiz' })
  aciklama?: string;

  @IsOptional()
  @IsString({ message: 'Ölçü geçersiz' })
  @MaxLength(80, { message: 'Ölçü en fazla 80 karakter olabilir' })
  olcu?: string;
}
