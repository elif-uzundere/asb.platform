import { Palet, PaletGuncelleVerisi, PaletOlusturVerisi } from './palet';
import { PaletTesisiBilgisi } from './palet-tesisi-bilgisi';

export abstract class PaletTesisiRepository {
  abstract tesisBilgisiGetir(): Promise<PaletTesisiBilgisi | null>;

  /** Herkese açık liste — sadece aktif olanlar. */
  abstract paletleriGetir(): Promise<Palet[]>;

  /** Palet Tesisi yönetim ekranı — pasif olanlar dahil hepsi. */
  abstract tumPaletleriGetir(): Promise<Palet[]>;

  abstract paletIdIleBul(id: string): Promise<Palet | null>;

  abstract paletOlustur(veri: PaletOlusturVerisi): Promise<Palet>;

  abstract paletGuncelle(id: string, veri: PaletGuncelleVerisi): Promise<Palet>;
}