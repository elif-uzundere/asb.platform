import { SetMetadata } from '@nestjs/common';
import type { YetkiKodu } from '@asb/shared-types';

export const YETKI_METADATA_ANAHTARI = 'gerekli_yetkiler';

export const Yetki = (...yetkiler: YetkiKodu[]) => SetMetadata(YETKI_METADATA_ANAHTARI, yetkiler);
