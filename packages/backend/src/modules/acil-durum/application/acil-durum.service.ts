import { Injectable } from '@nestjs/common';
import type { KullaniciRolu } from '@asb/shared-types';

import {
  ACIL_DURUM_TUR_EKIP_ESLEME,
  AciklamaZorunluException,
  AcilDurumBildirimDurumu,
  AcilDurumBildirimi,
  AcilDurumBilgisi,
  AcilDurumRepository,
  AcilDurumTuru,
  BaskaEkibeAitException,
  BildirimBulunamadiException,
  ToplanmaAlani,
} from '../domain';
import type { BildirimGonderPort } from '../../../shared/infrastructure/bildirim/bildirim-gonder.port';
import type { KullaniciSorgulamaPort } from '../../auth/adapters/public/kullanici-sorgulama.port';

@Injectable()
export class AcilDurumService {
  constructor(
    private readonly acilDurumRepository: AcilDurumRepository,
    private readonly bildirimGonder: BildirimGonderPort,
    private readonly kullaniciSorgulama: KullaniciSorgulamaPort,
  ) {}

  async bilgileriGetir(): Promise<AcilDurumBilgisi[]> {
    return this.acilDurumRepository.bilgileriGetir();
  }

  async toplanmaAlanlariniGetir(): Promise<ToplanmaAlani[]> {
    return this.acilDurumRepository.toplanmaAlanlariniGetir();
  }

  /**
   * BR-5: konum toplanmıyor (harita modülü kapsam dışı), bu yüzden bildirimin
   * anlamlı olabilmesi için açıklama zorunlu — kural entity'de değil burada,
   * çünkü sadece bir alanın boş/dolu kontrolü, entity'nin bilmesi gereken bir
   * durum makinesi/ilişki kuralı değil.
   *
   * Bildirim oluşunca türe göre ilgili EKİBİN TÜMÜNE (tek kişi değil) bildirim
   * gönderilir — 14.08.2026, Berzan'ın kararı. Bu modülün kendi bildirim
   * mantığı: paylaşılan transport (BildirimGonderPort) kullanılıyor ama
   * "kime/ne zaman" kararı Cookzone'daki gibi bu servisin kendi işi, merkezi
   * bir "bildirim motoru"na taşınmadı.
   */
  async bildirimOlustur(kullaniciId: string, tur: AcilDurumTuru, aciklama: string | null): Promise<AcilDurumBildirimi> {
    if (!aciklama || aciklama.trim().length === 0) {
      throw new AciklamaZorunluException();
    }
    const bildirim = await this.acilDurumRepository.bildirimOlustur({ kullaniciId, tur, aciklama: aciklama.trim() });

    const hedefRol = ACIL_DURUM_TUR_EKIP_ESLEME[tur];
    const ekipUyeleri = await this.kullaniciSorgulama.rolIleKullanicilariGetir(hedefRol);
    for (const uye of ekipUyeleri) {
      await this.bildirimGonder.gonder(
        uye.id,
        'Yeni Acil Durum Bildirimi',
        bildirim.aciklama ?? '',
        { tur, bildirimId: bildirim.id },
      );
    }

    return bildirim;
  }

  async bildirimlerimGetir(kullaniciId: string): Promise<AcilDurumBildirimi[]> {
    return this.acilDurumRepository.bildirimlerimGetir(kullaniciId);
  }

  /** Ekip görünümü — girişteki rolün karşılık geldiği türün tüm bildirimleri. */
  async ekibeGelenBildirimleriGetir(kullaniciRolu: KullaniciRolu): Promise<AcilDurumBildirimi[]> {
    const tur = this.rolunTuruGetir(kullaniciRolu);
    return this.acilDurumRepository.turIleListele(tur);
  }

  async bildirimDurumGuncelle(
    id: string,
    durum: AcilDurumBildirimDurumu,
    istekYapanRol: KullaniciRolu,
  ): Promise<AcilDurumBildirimi> {
    const bildirim = await this.acilDurumRepository.bildirimIdIleBul(id);
    if (!bildirim) {
      throw new BildirimBulunamadiException();
    }
    const yetkiliRol = ACIL_DURUM_TUR_EKIP_ESLEME[bildirim.tur];
    if (yetkiliRol !== istekYapanRol) {
      throw new BaskaEkibeAitException();
    }
    return this.acilDurumRepository.bildirimDurumGuncelle(id, durum);
  }

  private rolunTuruGetir(rol: KullaniciRolu): AcilDurumTuru {
    const bulunan = Object.entries(ACIL_DURUM_TUR_EKIP_ESLEME).find(([, r]) => r === rol);
    if (!bulunan) {
      throw new BaskaEkibeAitException();
    }
    return bulunan[0] as AcilDurumTuru;
  }
}