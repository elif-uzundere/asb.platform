import { Injectable } from '@nestjs/common';

import {
  AciklamaZorunluException,
  AcilDurumBildirimi,
  AcilDurumBilgisi,
  AcilDurumRepository,
  ToplanmaAlani,
} from '../domain';

@Injectable()
export class AcilDurumService {
  constructor(
    private readonly acilDurumRepository: AcilDurumRepository,
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
   */
  async bildirimOlustur(kullaniciId: string, tur: AcilDurumBildirimi['tur'], aciklama: string | null): Promise<AcilDurumBildirimi> {
    if (!aciklama || aciklama.trim().length === 0) {
      throw new AciklamaZorunluException();
    }
    return this.acilDurumRepository.bildirimOlustur({ kullaniciId, tur, aciklama: aciklama.trim() });
  }

  async bildirimlerimGetir(kullaniciId: string): Promise<AcilDurumBildirimi[]> {
    return this.acilDurumRepository.bildirimlerimGetir(kullaniciId);
  }
}