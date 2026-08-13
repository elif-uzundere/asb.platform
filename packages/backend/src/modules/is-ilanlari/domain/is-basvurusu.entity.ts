import type { IsBasvurusuDurumu } from '@asb/shared-types';

export type { IsBasvurusuDurumu };

export class IsBasvurusu {
  constructor(
    readonly id: string,
    readonly isIlaniId: string,
    readonly kullaniciId: string,
    readonly basvuruTarihi: Date,
    readonly durum: IsBasvurusuDurumu,
    readonly cvUrl: string | null = null,
  ) {}

  /** Yeni başvuru her zaman `beklemede` başlar — firma yetkilisi henüz incelemedi. */
  static yeniBasvuru(id: string, isIlaniId: string, kullaniciId: string, cvUrl: string | null = null): IsBasvurusu {
    return new IsBasvurusu(id, isIlaniId, kullaniciId, new Date(), 'beklemede', cvUrl);
  }
}
