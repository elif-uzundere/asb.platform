import { AcilDurumBilgisi } from './acil-durum-birimi';
import { AcilDurumBildirimDurumu, AcilDurumBildirimi, AcilDurumBildirimiOlusturVerisi, AcilDurumTuru } from './acil-durum-bildirimi';
import { ToplanmaAlani } from './toplanma-alani';

export abstract class AcilDurumRepository {
  abstract bilgileriGetir(): Promise<AcilDurumBilgisi[]>;

  abstract toplanmaAlanlariniGetir(): Promise<ToplanmaAlani[]>;

  abstract bildirimOlustur(veri: AcilDurumBildirimiOlusturVerisi): Promise<AcilDurumBildirimi>;

  /** Kullanıcının kendi gönderdiği bildirimler (Profil → Acil Durum Bildirimlerim). */
  abstract bildirimlerimGetir(kullaniciId: string): Promise<AcilDurumBildirimi[]>;

  /** Ekip görünümü — kendi türüne düşen tüm bildirimler. */
  abstract turIleListele(tur: AcilDurumTuru): Promise<AcilDurumBildirimi[]>;

  abstract bildirimIdIleBul(id: string): Promise<AcilDurumBildirimi | null>;

  abstract bildirimDurumGuncelle(id: string, durum: AcilDurumBildirimDurumu): Promise<AcilDurumBildirimi>;
}