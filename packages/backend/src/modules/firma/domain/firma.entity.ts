import type { FirmaOnayDurumu, FirmaOlusturRequest } from '@asb/shared-types';

// `FirmaOnayDurumu` artık burada tanımlanmıyor, sözleşmeden (shared-types)
// geliyor ve kolay erişim için yeniden dışa açılıyor. Sebep: aynı birlik iki
// yerde tanımlıysa biri değişip diğeri eski kalabilir. Tek kaynak = shared-types.
export type { FirmaOnayDurumu };

export class Firma {
  constructor(
    readonly id: string,
    readonly ad: string,
    readonly logoUrl: string | null,
    readonly sektor: string,
    readonly adres: string,
    readonly telefon: string | null,
    readonly eposta: string | null,
    readonly onayDurumu: FirmaOnayDurumu,
    readonly aktif: boolean,
    readonly webAdres: string | null,
    readonly kurulusTarihi: Date | null,
    readonly personelSayisi: number | null,
    readonly guncellemeTarihi: Date,
  ) {}

  /**
   * BR-1'in kod içindeki yeri: yeni firma kaydı HER ZAMAN `beklemede` başlar.
   *
   * Bu kural bilerek burada — controller'da ya da servis gövdesinde değil.
   * Böylece firmayı kim oluşturursa oluştursun (bugün admin, yarın firma
   * yetkilisi başvurusu) kuralı atlayamaz: `onayDurumu`'nu dışarıdan set
   * etmenin bir yolu yok.
   */
  static yeniKayit(id: string, dto: FirmaOlusturRequest): Firma {
    return new Firma(
      id,
      dto.ad,
      dto.logoUrl ?? null,
      dto.sektor,
      dto.adres,
      dto.telefon ?? null,
      dto.eposta ?? null,
      'beklemede',
      true,
      dto.webAdres ?? null,
      dto.kurulusTarihi ? new Date(dto.kurulusTarihi) : null,
      dto.personelSayisi ?? null,
      // Gerçek değeri Prisma `@updatedAt` ile DB'de üretiyor — bu sadece
      // kayıt henüz veritabanına yazılmadan önceki geçici bir değer,
      // `entiteyeCevir` gerçek satırı okuyunca üzerine yazılacak.
      new Date(),
    );
  }

  /** Herkese açık listede/detayda görünmeye uygun mu? */
  goruntulenebilir(): boolean {
    return this.onayDurumu === 'onaylandi' && this.aktif;
  }

  /**
   * `reddedildi` → `onaylandi` geçişine izin var (admin kararını
   * değiştirebilir). Ama zaten onaylı olanı tekrar onaylamak bir hatadır —
   * admin yanlış satıra bastığını böyle fark eder.
   */
  onaylanabilir(): boolean {
    return this.onayDurumu !== 'onaylandi';
  }
}
