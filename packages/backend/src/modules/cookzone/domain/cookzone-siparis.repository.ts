import { CookzoneSiparis, CookzoneSiparisDurumu, CookzoneSiparisKalemi } from './cookzone-siparis.entity';

export interface CookzoneSiparisRepository {
  /** `kalemler`deki `adet`ler `siparis.id`ye bağlı ayrı satırlar olarak, aynı işlemde yazılır. */
  olustur(
    siparis: CookzoneSiparis,
    kalemler: { menuOgesiId: string; adet: number }[],
  ): Promise<CookzoneSiparis>;

  idIleBul(id: string): Promise<CookzoneSiparis | null>;

  /** Müşterinin kendi siparişleri — Profil → Siparişlerim benzeri bir görünüm. */
  kullaniciyaGoreListele(kullaniciId: string): Promise<CookzoneSiparis[]>;

  /** `cookzone_yetkilisi`nin sipariş kuyruğu. */
  isletmeyeGoreListele(isletmeId: string): Promise<CookzoneSiparis[]>;

  durumGuncelle(id: string, durum: CookzoneSiparisDurumu): Promise<CookzoneSiparis>;

  /** Fiyat/isim, satır yazılırken saklanmıyor — okurken menü öğesine join edilir (bkz. adapter). */
  kalemleriGetir(siparisId: string): Promise<CookzoneSiparisKalemi[]>;
}
