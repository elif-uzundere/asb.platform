import { randomUUID } from 'crypto';
import {
  IsIlani,
  IsBasvurusu,
  IsIlaniRepository,
  IsBasvurusuRepository,
  IsIlaniBulunamadiException,
  FirmaOnayliDegilException,
  BaskaFirmayaAitException,
  ZatenBasvurulduException,
  IlanKapaliException,
  BasvuruBulunamadiException,
} from '../domain';
import type { FirmaSorgulamaPort } from '../../firma/adapters/public/firma-sorgulama.port';
import type { IsIlaniListeRequest, IsIlaniOlusturRequest, IsBasvurusuDurumGuncelleRequest } from '@asb/shared-types';
import type { BildirimGonderPort } from '../../../shared/infrastructure/bildirim/bildirim-gonder.port';

const DURUM_ETIKETI: Record<IsBasvurusuDurumGuncelleRequest['durum'], string> = {
  incelendi: 'incelendi olarak işaretlendi',
  reddedildi: 'reddedildi',
  kabul: 'kabul edildi',
};

/**
 * Saf TypeScript — NestJS decorator'ı YOK (mimari kural 2), firma.service.ts
 * ile aynı desen. `firmaSorgulama` firma modülünün public port'u: bu servis
 * firma'nın domain/persistence katmanını hiç görmüyor, sadece bu dar
 * arayüzü (isOnayli/adiGetir) biliyor — mimari kural 3.
 *
 * `bildirimGonder`: her modülün bildirim mantığı kendi service'inde kalır
 * (14.08.2026, Berzan'ın kararı — acil-durum.service.ts'teki aynı gerekçe).
 * Sadece transport (BildirimGonderPort) paylaşılıyor, "kime/ne zaman" kararı
 * burada: başvuru gelince ilanı açan kişiye, durum değişince başvuru
 * sahibine.
 */
export class IsIlaniService {
  constructor(
    private readonly isIlaniRepo: IsIlaniRepository,
    private readonly basvuruRepo: IsBasvurusuRepository,
    private readonly firmaSorgulama: FirmaSorgulamaPort,
    private readonly bildirimGonder: BildirimGonderPort,
  ) {}

  async listele(filtre: IsIlaniListeRequest): Promise<IsIlani[]> {
    return this.isIlaniRepo.listele(filtre);
  }

  async detay(id: string): Promise<IsIlani> {
    const ilan = await this.isIlaniRepo.idIleBul(id);
    if (!ilan) {
      throw new IsIlaniBulunamadiException();
    }
    return ilan;
  }

  /** Firma adını, listede/detayda göstermek için `IsIlaniController` bunu ayrıca çağırır. */
  async firmaAdi(firmaId: string): Promise<string | null> {
    return this.firmaSorgulama.adiGetir(firmaId);
  }

  // ── Firma yetkilisi işlemleri ────────────────────────────────────────────

  async olustur(firmaId: string, olusturanKullaniciId: string, dto: IsIlaniOlusturRequest): Promise<IsIlani> {
    // BR-2 burada uygulanıyor: onaylı olmayan firma ilan açamaz. Kural
    // entity'de DEĞİL — çünkü firma onay durumunu bilmek için başka bir
    // modüle sormak gerekiyor, bu da application katmanının işi.
    const onayli = await this.firmaSorgulama.isOnayli(firmaId);
    if (!onayli) {
      throw new FirmaOnayliDegilException();
    }
    const yeniIlan = IsIlani.yeniIlan(randomUUID(), firmaId, olusturanKullaniciId, dto);
    return this.isIlaniRepo.olustur(yeniIlan);
  }

  async kapat(id: string, istekyapanFirmaId: string): Promise<IsIlani> {
    const ilan = await this.sahiplikDogrula(id, istekyapanFirmaId);
    if (!ilan.kapatilabilir()) {
      throw new IlanKapaliException();
    }
    return this.isIlaniRepo.durumGuncelle(id, 'kapali');
  }

  async basvurulariGetir(id: string, istekyapanFirmaId: string): Promise<IsBasvurusu[]> {
    await this.sahiplikDogrula(id, istekyapanFirmaId);
    return this.basvuruRepo.ilanaGoreListele(id);
  }

  /** Firma yetkilisinin bir başvuruyu incele/kabul/red kararı. */
  async basvuruDurumGuncelle(
    ilanId: string,
    basvuruId: string,
    istekyapanFirmaId: string,
    dto: IsBasvurusuDurumGuncelleRequest,
  ): Promise<IsBasvurusu> {
    const ilan = await this.sahiplikDogrula(ilanId, istekyapanFirmaId);
    const basvuru = await this.basvuruRepo.idIleBul(basvuruId);
    if (!basvuru || basvuru.isIlaniId !== ilanId) {
      throw new BasvuruBulunamadiException();
    }
    const guncellenenBasvuru = await this.basvuruRepo.durumGuncelle(basvuruId, dto.durum);

    await this.bildirimGonder.gonder(
      basvuru.kullaniciId,
      'Başvuru Durumunuz Güncellendi',
      `"${ilan.baslik}" ilanına yaptığınız başvuru ${DURUM_ETIKETI[dto.durum]}.`,
      { isIlaniId: ilanId, basvuruId, durum: dto.durum },
    );

    return guncellenenBasvuru;
  }

  // ── Başvuru ──────────────────────────────────────────────────────────────

  async basvur(isIlaniId: string, kullaniciId: string, cvUrl: string | null = null): Promise<IsBasvurusu> {
    const ilan = await this.isIlaniRepo.idIleBul(isIlaniId);
    if (!ilan) {
      throw new IsIlaniBulunamadiException();
    }
    if (ilan.durum !== 'aktif') {
      throw new IlanKapaliException();
    }
    const mevcutBasvuru = await this.basvuruRepo.kullaniciVeIlanaGoreBul(kullaniciId, isIlaniId);
    if (mevcutBasvuru) {
      throw new ZatenBasvurulduException();
    }
    const yeniBasvuru = IsBasvurusu.yeniBasvuru(randomUUID(), isIlaniId, kullaniciId, cvUrl);
    const olusturulanBasvuru = await this.basvuruRepo.olustur(yeniBasvuru);

    await this.bildirimGonder.gonder(
      ilan.olusturanKullaniciId,
      'Yeni Başvuru Aldınız',
      `"${ilan.baslik}" ilanınıza yeni bir başvuru geldi.`,
      { isIlaniId, basvuruId: olusturulanBasvuru.id },
    );

    return olusturulanBasvuru;
  }

  /** Profil → Başvurularım: kullanıcının kendi yaptığı tüm başvurular. */
  async basvurularim(kullaniciId: string): Promise<IsBasvurusu[]> {
    return this.basvuruRepo.kullaniciyaGoreListele(kullaniciId);
  }

  /** İlanın gerçekten `istekyapanFirmaId`'ye ait olduğunu doğrular, ilanı döner. */
  private async sahiplikDogrula(ilanId: string, istekyapanFirmaId: string): Promise<IsIlani> {
    const ilan = await this.isIlaniRepo.idIleBul(ilanId);
    if (!ilan) {
      throw new IsIlaniBulunamadiException();
    }
    if (ilan.firmaId !== istekyapanFirmaId) {
      throw new BaskaFirmayaAitException();
    }
    return ilan;
  }
}
