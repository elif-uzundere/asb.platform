import { Palet } from './palet';
import { PaletTesisiBilgisi } from './palet-tesisi-bilgisi';

export abstract class PaletTesisiRepository {
  abstract tesisBilgisiGetir(): Promise<PaletTesisiBilgisi | null>;

  abstract paletleriGetir(): Promise<Palet[]>;
}