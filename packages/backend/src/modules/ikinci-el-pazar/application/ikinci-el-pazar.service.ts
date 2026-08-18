import { Injectable } from '@nestjs/common';

import {
  IkinciElIlani,
  IkinciElRepository,
} from '../domain';

import { IkinciElIlaniOlusturDto } from '../dto';

@Injectable()
export class IkinciElPazarService {
  constructor(
    private readonly ikinciElRepository:
      IkinciElRepository,
  ) {}

  /**
   * Yayında bulunan aktif ikinci el ilanlarını getirir.
   */
  async aktifIlanlariGetir(): Promise<IkinciElIlani[]> {
    return this.ikinciElRepository.aktifIlanlariGetir();
  }

  /**
   * Yeni ikinci el ilanı oluşturur.
   *
   * kullaniciId:
   * JWT'den gelir.
   *
   * sehir:
   * Kullanıcıdan alınmaz.
   * ASB konumu sabit olduğu için backend otomatik belirler.
   */
  async ilanOlustur(
    kullaniciId: string,
    dto: IkinciElIlaniOlusturDto,
    fotografUrls: string[],
  ): Promise<IkinciElIlani> {
    return this.ikinciElRepository.ilanOlustur({
      kullaniciId,
      baslik: dto.baslik.trim(),
      aciklama: dto.aciklama.trim(),
      fiyat: dto.fiyat,
      kategori: dto.kategori.trim(),
      urunDurumu: dto.urunDurumu.trim(),
      iletisimTelefonu: dto.iletisimTelefonu.trim(),
      fotografUrls,
    });
  }
}