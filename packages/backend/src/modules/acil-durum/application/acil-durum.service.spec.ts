import { AcilDurumService } from './acil-durum.service';
import { AciklamaZorunluException, AcilDurumBildirimi, AcilDurumRepository } from '../domain';

function bildirimOlustur(overrides?: Partial<AcilDurumBildirimi>): AcilDurumBildirimi {
  return {
    id: 'b1',
    kullaniciId: 'k1',
    tur: 'yangin',
    aciklama: 'Duman görüldü',
    durum: 'yeni',
    olusturmaTarihi: new Date(),
    ...overrides,
  };
}

function repoOlustur(overrides?: Partial<AcilDurumRepository>): AcilDurumRepository {
  return {
    bilgileriGetir: jest.fn().mockResolvedValue([]),
    toplanmaAlanlariniGetir: jest.fn().mockResolvedValue([]),
    bildirimOlustur: jest.fn(),
    bildirimlerimGetir: jest.fn().mockResolvedValue([]),
    ...overrides,
  };
}

describe('AcilDurumService', () => {
  describe('bildirimOlustur (BR-5)', () => {
    it('açıklama boşsa AciklamaZorunluException fırlatır', async () => {
      const servis = new AcilDurumService(repoOlustur());

      await expect(servis.bildirimOlustur('k1', 'yangin', '')).rejects.toBeInstanceOf(AciklamaZorunluException);
    });

    it('açıklama sadece boşluklardan oluşuyorsa AciklamaZorunluException fırlatır', async () => {
      const servis = new AcilDurumService(repoOlustur());

      await expect(servis.bildirimOlustur('k1', 'yangin', '   ')).rejects.toBeInstanceOf(AciklamaZorunluException);
    });

    it('açıklama doluysa bildirim oluşturur', async () => {
      const yeniBildirim = bildirimOlustur();
      const repo = repoOlustur({ bildirimOlustur: jest.fn().mockResolvedValue(yeniBildirim) });
      const servis = new AcilDurumService(repo);

      const sonuc = await servis.bildirimOlustur('k1', 'yangin', 'Duman görüldü');

      expect(sonuc).toBe(yeniBildirim);
      expect(repo.bildirimOlustur).toHaveBeenCalledWith({ kullaniciId: 'k1', tur: 'yangin', aciklama: 'Duman görüldü' });
    });
  });

  describe('bildirimlerimGetir', () => {
    it('kullanicinin kendi bildirimlerini repository uzerinden doner', async () => {
      const kendiBildirimi = bildirimOlustur();
      const repo = repoOlustur({ bildirimlerimGetir: jest.fn().mockResolvedValue([kendiBildirimi]) });
      const servis = new AcilDurumService(repo);

      const sonuc = await servis.bildirimlerimGetir('k1');

      expect(sonuc).toEqual([kendiBildirimi]);
      expect(repo.bildirimlerimGetir).toHaveBeenCalledWith('k1');
    });
  });
});
