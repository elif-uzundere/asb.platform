import type { IsIlaniDurumu, IsIlaniOlusturRequest } from '@asb/shared-types';

export type { IsIlaniDurumu };

export class IsIlani {
  constructor(
    readonly id: string,
    readonly firmaId: string,
    readonly olusturanKullaniciId: string,
    readonly baslik: string,
    readonly aciklama: string,
    readonly konum: string | null,
    readonly yayinTarihi: Date,
    readonly durum: IsIlaniDurumu,
  ) {}

  /**
   * Yeni ilan HER ZAMAN `aktif` başlar — `Firma.yeniKayit`'teki BR-1
   * deseninin aynısı: durum dışarıdan set edilemiyor, kural entity'de.
   * BR-2 (sadece onaylı firma ilan açabilir) burada DEĞİL — o, firma
   * bilgisine ihtiyaç duyduğu için `IsIlaniService.olustur()`'da uygulanıyor.
   */
  static yeniIlan(
    id: string,
    firmaId: string,
    olusturanKullaniciId: string,
    dto: IsIlaniOlusturRequest,
  ): IsIlani {
    return new IsIlani(
      id,
      firmaId,
      olusturanKullaniciId,
      dto.baslik,
      dto.aciklama,
      dto.konum ?? null,
      new Date(),
      'aktif',
    );
  }

  /** Zaten kapalı bir ilanı tekrar kapatmak admin'in yanlış satıra basması anlamına gelir. */
  kapatilabilir(): boolean {
    return this.durum === 'aktif';
  }
}
