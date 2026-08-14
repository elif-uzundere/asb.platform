import { AcilDurumBilgisi } from './acil-durum-birimi';
import { AcilDurumBildirimi, AcilDurumBildirimiOlusturVerisi } from './acil-durum-bildirimi';
import { ToplanmaAlani } from './toplanma-alani';

export abstract class AcilDurumRepository {
  abstract bilgileriGetir(): Promise<AcilDurumBilgisi[]>;

  abstract toplanmaAlanlariniGetir(): Promise<ToplanmaAlani[]>;

  abstract bildirimOlustur(veri: AcilDurumBildirimiOlusturVerisi): Promise<AcilDurumBildirimi>;

  /** Kullanıcının kendi gönderdiği bildirimler (Profil → Acil Durum Bildirimlerim). */
  abstract bildirimlerimGetir(kullaniciId: string): Promise<AcilDurumBildirimi[]>;
}