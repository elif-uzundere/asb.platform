import { randomUUID } from 'crypto';
import {
  CookzoneIsletme,
  CookzoneIsletmeBulunamadiException,
  CookzoneIsletmeRepository,
  CookzoneMenuOgesi,
  CookzoneMenuOgesiBulunamadiException,
  CookzoneSiparis,
  CookzoneSiparisBulunamadiException,
  CookzoneSiparisKalemi,
  CookzoneSiparisRepository,
  BaskaIsletmeyeAitException,
  BosSepetIleSiparisVerilemezException,
  GecmisSaateSiparisVerilemezException,
  SiparisIlerletilemezException,
} from '../domain';
import type { BildirimGonderPort } from '../../../shared/infrastructure/bildirim/bildirim-gonder.port';
import type { CookzoneSiparisKalemiRequest } from '@asb/shared-types';

/**
 * Saf TypeScript — NestJS decorator'ı YOK (mimari kural 2), is-ilani.service.ts
 * ile aynı desen. `bildirimGonder` shared/infrastructure'dan (global modül,
 * mimari kural 3'ün kapsamadığı, PrismaService'le aynı statüde) enjekte
 * ediliyor — Cookzone'a özel değil, ortak bir altyapı parçası.
 */
export class CookzoneService {
  constructor(
    private readonly isletmeRepo: CookzoneIsletmeRepository,
    private readonly siparisRepo: CookzoneSiparisRepository,
    private readonly bildirimGonder: BildirimGonderPort,
  ) {}

  // ── Katalog (herkese açık) ───────────────────────────────────────────────

  async isletmeler(): Promise<CookzoneIsletme[]> {
    return this.isletmeRepo.tumunuListele();
  }

  async isletmeDetay(id: string): Promise<CookzoneIsletme> {
    const isletme = await this.isletmeRepo.idIleBul(id);
    if (!isletme) {
      throw new CookzoneIsletmeBulunamadiException();
    }
    return isletme;
  }

  async menuGetir(isletmeId: string): Promise<CookzoneMenuOgesi[]> {
    return this.isletmeRepo.menuOgeleriGetir(isletmeId);
  }

  // ── Sipariş — müşteri tarafı ─────────────────────────────────────────────

  async siparisOlustur(
    kullaniciId: string,
    isletmeId: string,
    alinmaSaati: Date,
    kalemler: CookzoneSiparisKalemiRequest[],
  ): Promise<CookzoneSiparis> {
    if (kalemler.length === 0) {
      throw new BosSepetIleSiparisVerilemezException();
    }
    if (alinmaSaati.getTime() <= Date.now()) {
      throw new GecmisSaateSiparisVerilemezException();
    }

    // Toplam tutar kalemlerden hesaplanır (BR) — şema kalem satırında fiyat
    // saklamıyor (bkz. cookzone-siparis.repository.ts notu), bu yüzden her
    // kalemin GÜNCEL fiyatını burada okuyup topluyoruz.
    let toplamTutar = 0;
    for (const kalem of kalemler) {
      const menuOgesi = await this.isletmeRepo.menuOgesiIdIleBul(kalem.menuOgesiId);
      if (!menuOgesi) {
        throw new CookzoneMenuOgesiBulunamadiException();
      }
      toplamTutar += menuOgesi.fiyat * kalem.adet;
    }

    const yeniSiparis = CookzoneSiparis.yeniSiparis(
      randomUUID(),
      kullaniciId,
      isletmeId,
      toplamTutar,
      alinmaSaati,
    );
    return this.siparisRepo.olustur(yeniSiparis, kalemler);
  }

  async siparislerim(kullaniciId: string): Promise<CookzoneSiparis[]> {
    return this.siparisRepo.kullaniciyaGoreListele(kullaniciId);
  }

  async siparisKalemleri(siparisId: string): Promise<CookzoneSiparisKalemi[]> {
    return this.siparisRepo.kalemleriGetir(siparisId);
  }

  // ── Sipariş — cookzone_yetkilisi tarafı ─────────────────────────────────

  async isletmeSiparisleri(isletmeId: string): Promise<CookzoneSiparis[]> {
    return this.siparisRepo.isletmeyeGoreListele(isletmeId);
  }

  /**
   * Sıradaki duruma geçirir (kabul et / hazırlanıyor / hazır / teslim
   * edildi — hepsi aynı metot, entity hangi adımda olduğunu zaten biliyor).
   * `hazir`a geçince müşteriye bildirim gider — akışın tek tetikleyici noktası.
   */
  async siparisIlerlet(id: string, istekYapanIsletmeId: string): Promise<CookzoneSiparis> {
    const siparis = await this.sahiplikDogrula(id, istekYapanIsletmeId);
    const sonrakiDurum = siparis.sonrakiDurum();
    if (!sonrakiDurum) {
      throw new SiparisIlerletilemezException();
    }

    const guncellenmisSiparis = await this.siparisRepo.durumGuncelle(id, sonrakiDurum);

    if (siparis.bildirimGerektirir(sonrakiDurum)) {
      const isletme = await this.isletmeRepo.idIleBul(siparis.isletmeId);
      await this.bildirimGonder.gonder(
        siparis.kullaniciId,
        'Siparişiniz hazır',
        `${isletme?.ad ?? 'Cookzone'} siparişiniz hazır, gelip alabilirsiniz.`,
        { tur: 'cookzone_siparis', siparisId: siparis.id },
      );
    }

    return guncellenmisSiparis;
  }

  private async sahiplikDogrula(siparisId: string, istekYapanIsletmeId: string): Promise<CookzoneSiparis> {
    const siparis = await this.siparisRepo.idIleBul(siparisId);
    if (!siparis) {
      throw new CookzoneSiparisBulunamadiException();
    }
    if (siparis.isletmeId !== istekYapanIsletmeId) {
      throw new BaskaIsletmeyeAitException();
    }
    return siparis;
  }
}
