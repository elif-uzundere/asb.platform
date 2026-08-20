import type { CookzoneSiparisDurumu } from '@asb/shared-types';

export type { CookzoneSiparisDurumu };

/**
 * Durum sırası sabit ve atlanamaz. `sonrakiDurum()` her zaman bir sonraki
 * adımı döner, servis katmanı bunun dışında bir durum set edemez. Kural
 * burada (entity'de) yaşıyor ki "hazırlanıyor"dan direkt "teslim edildi"ye
 * atlamak gibi bir hata mümkün olmasın. Akış: kabul et → hazırlanıyor →
 * hazır (bildirim) → teslim edildi.
 */
const DURUM_SIRASI: CookzoneSiparisDurumu[] = [
  'beklemede',
  'alindi',
  'hazirlaniyor',
  'hazir',
  'teslim_edildi',
];

export class CookzoneSiparisKalemi {
  constructor(
    readonly id: string,
    readonly siparisId: string,
    readonly menuOgesiId: string,
    readonly menuOgesiAdi: string,
    readonly birimFiyat: number,
    readonly adet: number,
  ) {}
}

export class CookzoneSiparis {
  constructor(
    readonly id: string,
    readonly kullaniciId: string,
    readonly isletmeId: string,
    readonly durum: CookzoneSiparisDurumu,
    readonly toplamTutar: number,
    /** Teslimat yok, müşterinin "şu saatte gelip alacağım" dediği zaman. */
    readonly alinmaSaati: Date,
    readonly olusturmaTarihi: Date,
  ) {}

  /**
   * Yeni sipariş her zaman `beklemede` başlar, `Firma.yeniKayit`'teki BR-1
   * deseninin aynısı. İşletme siparişi elle kabul etmeden `alindi`ya geçmez.
   */
  static yeniSiparis(
    id: string,
    kullaniciId: string,
    isletmeId: string,
    toplamTutar: number,
    alinmaSaati: Date,
  ): CookzoneSiparis {
    return new CookzoneSiparis(id, kullaniciId, isletmeId, 'beklemede', toplamTutar, alinmaSaati, new Date());
  }

  /** Sıradaki durum — `teslim_edildi` sondur, o noktada null döner. */
  sonrakiDurum(): CookzoneSiparisDurumu | null {
    const indeks = DURUM_SIRASI.indexOf(this.durum);
    return indeks < DURUM_SIRASI.length - 1 ? DURUM_SIRASI[indeks + 1] : null;
  }

  ilerletilebilir(): boolean {
    return this.sonrakiDurum() !== null;
  }

  /** "Hazır" olduğunda müşteriye bildirim gitmesi gereken tek an burası. */
  bildirimGerektirir(sonrakiDurum: CookzoneSiparisDurumu): boolean {
    return sonrakiDurum === 'hazir';
  }
}
