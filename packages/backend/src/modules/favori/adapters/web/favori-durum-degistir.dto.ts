import { IsIn, IsNotEmpty, IsString } from 'class-validator';
import type { FavoriDurumDegistirRequest, FavoriHedefTuru } from '@asb/shared-types';

const GECERLI_HEDEF_TURLERI: FavoriHedefTuru[] = ['ikinci_el', 'firma', 'is_ilani'];

export class FavoriDurumDegistirDto implements FavoriDurumDegistirRequest {
  @IsIn(GECERLI_HEDEF_TURLERI, { message: 'Geçersiz favori türü' })
  hedefTuru!: FavoriHedefTuru;

  @IsString({ message: 'Hedef id geçersiz' })
  @IsNotEmpty({ message: 'Hedef id boş bırakılamaz' })
  hedefId!: string;
}
