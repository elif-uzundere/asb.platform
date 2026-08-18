import { randomUUID } from 'crypto';
import {
  CookzoneIsletme,
  CookzoneIsletmeBulunamadiException,
  CookzoneIsletmeRepository,
  CookzoneMenuOgesi,
  CookzoneMenuOgesiBulunamadiException,
  CookzoneMenuOgesiGuncellemeVerisi,
  CookzoneMenuOgesiOlusturmaVerisi,
  CookzoneSiparis,
  CookzoneSiparisBulunamadiException,
  CookzoneSiparisKalemi,
  CookzoneSiparisRepository,
  BaskaIsletmeninMenuOgesiException,
  BaskaIsletmeyeAitException,
  BosSepetIleSiparisVerilemezException,
  GecmisSaateSiparisVerilemezException,
  SiparisIlerletilemezException,
} from '../domain';
import type { BildirimGonderPort } from '../../../shared/infrastructure/bildirim/bildirim-gonder.port';
import type { KullaniciSorgulamaPort } from '../../auth/adapters/public/kullanici-sorgulama.port';
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
    private readonly kullaniciSorgulama: KullaniciSorgulamaPort,
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

  // ── Menü yönetimi — cookzone_yetkilisi tarafı ───────────────────────────

  async menuOgeleriTumunuGetir(isletmeId: string): Promise<CookzoneMenuOgesi[]> {
    return this.isletmeRepo.menuOgeleriTumunuGetir(isletmeId);
  }

  async menuOgesiOlustur(veri: CookzoneMenuOgesiOlusturmaVerisi): Promise<CookzoneMenuOgesi> {
    return this.isletmeRepo.menuOgesiOlustur(veri);
  }

  async menuOgesiGuncelle(
    id: string,
    istekYapanIsletmeId: string,
    veri: CookzoneMenuOgesiGuncellemeVerisi,
  ): Promise<CookzoneMenuOgesi> {
    await this.menuOgesiSahiplikDogrula(id, istekYapanIsletmeId);
    return this.isletmeRepo.menuOgesiGuncelle(id, veri);
  }

  async menuOgesiSil(id: string, istekYapanIsletmeId: string): Promise<void> {
    await this.menuOgesiSahiplikDogrula(id, istekYapanIsletmeId);
    await this.isletmeRepo.menuOgesiSil(id);
  }

  private async menuOgesiSahiplikDogrula(id: string, istekYapanIsletmeId: string): Promise<CookzoneMenuOgesi> {
    const menuOgesi = await this.isletmeRepo.menuOgesiIdIleBul(id);
    if (!menuOgesi) {
      throw new CookzoneMenuOgesiBulunamadiException();
    }
    if (menuOgesi.isletmeId !== istekYapanIsletmeId) {
      throw new BaskaIsletmeninMenuOgesiException();
    }
    return menuOgesi;
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
    const olusturulanSiparis = await this.siparisRepo.olustur(yeniSiparis, kalemler);

    // Yeni sipariş gelince işletmeye bağlı TÜM cookzone_yetkilisi
    // hesaplarına bildirim gider (18.08.2026, Berzan'ın kararı) — "hazır"
    // bildiriminin tersi yönü: burada müşteriden işletmeye gidiyor.
    const yetkililer = await this.kullaniciSorgulama.cookzoneIsletmesineGoreKullanicilariGetir(isletmeId);
    for (const yetkili of yetkililer) {
      await this.bildirimGonder.gonder(
        yetkili.id,
        'Yeni Sipariş Geldi',
        `Yeni bir sipariş alındı, toplam ${toplamTutar} ₺.`,
        { tur: 'cookzone_siparis', siparisId: olusturulanSiparis.id },
      );
    }

    return olusturulanSiparis;
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
