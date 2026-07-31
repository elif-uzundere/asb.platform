import { randomUUID } from 'crypto';
import {
  Firma,
  FirmaRepository,
  FirmaBulunamadiException,
  FirmaZatenOnayliException,
} from '../domain';
import type { FirmaListeRequest, FirmaOlusturRequest } from '@asb/shared-types';

/**
 * Saf TypeScript — NestJS decorator'ı YOK (mimari kural 2). Nest'e bağlanması
 * firma.module.ts içindeki `useFactory` ile yapılıyor. Bu sayede testte
 * `new FirmaService(sahteRepo)` demek yeterli, Nest'i ayağa kaldırmak gerekmiyor.
 */
export class FirmaService {
  constructor(private readonly firmaRepo: FirmaRepository) {}

  async listele(filtre: FirmaListeRequest): Promise<Firma[]> {
    // Süzgeç artık SQL'de (repository). Buradaki ikinci kontrol emniyet kemeri:
    // ileride biri repository sorgusunu değiştirirse görünmemesi gereken bir
    // kayıt sessizce dışarı sızmasın.
    const firmalar = await this.firmaRepo.listele(filtre);
    return firmalar.filter((firma) => firma.goruntulenebilir());
  }

  async detay(id: string): Promise<Firma> {
    const firma = await this.firmaRepo.idIleBul(id);
    // Onaylanmamış firma için de "bulunamadı" diyoruz — varlığını sızdırmamak
    // için 403 değil 404. Aksi halde id deneyerek onay kuyruğu öğrenilebilirdi.
    if (!firma || !firma.goruntulenebilir()) {
      throw new FirmaBulunamadiException();
    }
    return firma;
  }

  async sektorler(): Promise<string[]> {
    return this.firmaRepo.sektorleriGetir();
  }

  // ── Admin işlemleri ────────────────────────────────────────────────────

  async olustur(dto: FirmaOlusturRequest): Promise<Firma> {
    // BR-1 burada uygulanmıyor — `Firma.yeniKayit` uyguluyor. Servis sadece
    // id üretip kaydı yazıyor. Kural entity'de olduğu için atlanamaz.
    const yeniFirma = Firma.yeniKayit(randomUUID(), dto);
    return this.firmaRepo.olustur(yeniFirma);
  }

  async onayBekleyenler(): Promise<Firma[]> {
    return this.firmaRepo.onayBekleyenleriGetir();
  }

  async onayla(id: string): Promise<Firma> {
    const firma = await this.firmaRepo.idIleBul(id);
    if (!firma) {
      throw new FirmaBulunamadiException();
    }
    if (!firma.onaylanabilir()) {
      throw new FirmaZatenOnayliException();
    }
    return this.firmaRepo.onayDurumuGuncelle(id, 'onaylandi');
  }
}
