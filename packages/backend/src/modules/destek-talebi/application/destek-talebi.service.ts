import { DestekTalebiData, DestekTalebiOlusturmaVerisi, DestekTalebiRepository } from '../domain';
import type { BildirimGonderPort } from '../../../shared/infrastructure/bildirim/bildirim-gonder.port';
import type { KullaniciSorgulamaPort } from '../../auth/adapters/public/kullanici-sorgulama.port';

/**
 * Saf TypeScript — is-ilanlari/acil-durum'daki aynı gerekçe. Bu modül daha
 * önce 2 katmandı (basit CRUD, `application` yoktu) — bildirim kuralı
 * eklenince 3. katman gerekli hale geldi (docs/izlence'deki "katman derinliği
 * modüle göre değişir" ilkesi).
 *
 * TODO (18.08.2026, Berzan): Şu an "İK" diye ayrı bir kullanıcı rolü/hesabı
 * YOK — bilerek oluşturulmadı ("gerçek kullanıcıları girince yaparsın" dedi).
 * Bu yüzden bildirim geçici olarak `admin` rolündeki hesaplara gidiyor.
 * Gerçek İK ekibi hesapları tanımlanınca (muhtemelen acil-durum'daki ekip
 * rolleri gibi ayrı bir `ik_ekibi` rolü), aşağıdaki `'admin'` → `'ik_ekibi'`
 * olarak değiştirilmesi YETERLİ olacak — geri kalan akış aynı kalır.
 */
export class DestekTalebiService {
  constructor(
    private readonly destekTalebiRepository: DestekTalebiRepository,
    private readonly bildirimGonder: BildirimGonderPort,
    private readonly kullaniciSorgulama: KullaniciSorgulamaPort,
  ) {}

  async olustur(veri: DestekTalebiOlusturmaVerisi): Promise<DestekTalebiData> {
    const talep = await this.destekTalebiRepository.olustur(veri);

    // TODO: 'admin' yerine 'ik_ekibi' — yukarıdaki sınıf yorumuna bakın.
    const ikYerineGecici = await this.kullaniciSorgulama.rolIleKullanicilariGetir('admin');
    for (const kullanici of ikYerineGecici) {
      await this.bildirimGonder.gonder(
        kullanici.id,
        'Yeni Destek Talebi',
        talep.baslik,
        { destekTalebiId: talep.id },
      );
    }

    return talep;
  }

  async kullaniciyaGoreListele(kullaniciId: string): Promise<DestekTalebiData[]> {
    return this.destekTalebiRepository.kullaniciyaGoreListele(kullaniciId);
  }
}
