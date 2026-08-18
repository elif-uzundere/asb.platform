import { AcilDurumService } from './acil-durum.service';
import {
  AciklamaZorunluException,
  AcilDurumBildirimi,
  AcilDurumRepository,
  BaskaEkibeAitException,
  BildirimBulunamadiException,
} from '../domain';
import type { BildirimGonderPort } from '../../../shared/infrastructure/bildirim/bildirim-gonder.port';
import type { KullaniciSorgulamaPort } from '../../auth/adapters/public/kullanici-sorgulama.port';

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
    turIleListele: jest.fn().mockResolvedValue([]),
    bildirimIdIleBul: jest.fn().mockResolvedValue(null),
    bildirimDurumGuncelle: jest.fn(),
    ...overrides,
  };
}

function bildirimGonderOlustur(overrides?: Partial<BildirimGonderPort>): BildirimGonderPort {
  return {
    gonder: jest.fn().mockResolvedValue(undefined),
    ...overrides,
  };
}

function kullaniciSorgulamaOlustur(overrides?: Partial<KullaniciSorgulamaPort>): KullaniciSorgulamaPort {
  return {
    adSoyadGetir: jest.fn().mockResolvedValue('Test Kullanıcı'),
    rolIleKullanicilariGetir: jest.fn().mockResolvedValue([]),
    cookzoneIsletmesineGoreKullanicilariGetir: jest.fn().mockResolvedValue([]),
    ...overrides,
  };
}

describe('AcilDurumService', () => {
  describe('bildirimOlustur (BR-5)', () => {
    it('açıklama boşsa AciklamaZorunluException fırlatır', async () => {
      const servis = new AcilDurumService(repoOlustur(), bildirimGonderOlustur(), kullaniciSorgulamaOlustur());

      await expect(servis.bildirimOlustur('k1', 'yangin', '')).rejects.toBeInstanceOf(AciklamaZorunluException);
    });

    it('açıklama sadece boşluklardan oluşuyorsa AciklamaZorunluException fırlatır', async () => {
      const servis = new AcilDurumService(repoOlustur(), bildirimGonderOlustur(), kullaniciSorgulamaOlustur());

      await expect(servis.bildirimOlustur('k1', 'yangin', '   ')).rejects.toBeInstanceOf(AciklamaZorunluException);
    });

    it('açıklama doluysa bildirim oluşturur', async () => {
      const yeniBildirim = bildirimOlustur();
      const repo = repoOlustur({ bildirimOlustur: jest.fn().mockResolvedValue(yeniBildirim) });
      const servis = new AcilDurumService(repo, bildirimGonderOlustur(), kullaniciSorgulamaOlustur());

      const sonuc = await servis.bildirimOlustur('k1', 'yangin', 'Duman görüldü');

      expect(sonuc).toBe(yeniBildirim);
      expect(repo.bildirimOlustur).toHaveBeenCalledWith({ kullaniciId: 'k1', tur: 'yangin', aciklama: 'Duman görüldü' });
    });

    it('yangin turunde itfaiye_ekibinin tum uyelerine bildirim gonderir', async () => {
      const yeniBildirim = bildirimOlustur({ tur: 'yangin' });
      const repo = repoOlustur({ bildirimOlustur: jest.fn().mockResolvedValue(yeniBildirim) });
      const kullaniciSorgulama = kullaniciSorgulamaOlustur({
        rolIleKullanicilariGetir: jest.fn().mockResolvedValue([
          { id: 'u1', adSoyad: 'İtfaiyeci Bir' },
          { id: 'u2', adSoyad: 'İtfaiyeci İki' },
        ]),
      });
      const bildirimGonder = bildirimGonderOlustur();
      const servis = new AcilDurumService(repo, bildirimGonder, kullaniciSorgulama);

      await servis.bildirimOlustur('k1', 'yangin', 'Duman görüldü');

      expect(kullaniciSorgulama.rolIleKullanicilariGetir).toHaveBeenCalledWith('itfaiye_ekibi');
      expect(bildirimGonder.gonder).toHaveBeenCalledTimes(2);
      expect(bildirimGonder.gonder).toHaveBeenCalledWith('u1', expect.any(String), 'Duman görüldü', expect.any(Object));
    });

    it('saglik ve diger turleri farkli ekiplere gider (Tekin İSG ile şirket İSG karışmaz)', async () => {
      const kullaniciSorgulama = kullaniciSorgulamaOlustur();
      const repo1 = repoOlustur({ bildirimOlustur: jest.fn().mockResolvedValue(bildirimOlustur({ tur: 'saglik' })) });
      const servis1 = new AcilDurumService(repo1, bildirimGonderOlustur(), kullaniciSorgulama);
      await servis1.bildirimOlustur('k1', 'saglik', 'Fenalaştı');
      expect(kullaniciSorgulama.rolIleKullanicilariGetir).toHaveBeenLastCalledWith('tekin_isg_ekibi');

      const repo2 = repoOlustur({ bildirimOlustur: jest.fn().mockResolvedValue(bildirimOlustur({ tur: 'diger' })) });
      const servis2 = new AcilDurumService(repo2, bildirimGonderOlustur(), kullaniciSorgulama);
      await servis2.bildirimOlustur('k1', 'diger', 'Belirsiz durum');
      expect(kullaniciSorgulama.rolIleKullanicilariGetir).toHaveBeenLastCalledWith('sirket_isg_ekibi');
    });
  });

  describe('bildirimlerimGetir', () => {
    it('kullanicinin kendi bildirimlerini repository uzerinden doner', async () => {
      const kendiBildirimi = bildirimOlustur();
      const repo = repoOlustur({ bildirimlerimGetir: jest.fn().mockResolvedValue([kendiBildirimi]) });
      const servis = new AcilDurumService(repo, bildirimGonderOlustur(), kullaniciSorgulamaOlustur());

      const sonuc = await servis.bildirimlerimGetir('k1');

      expect(sonuc).toEqual([kendiBildirimi]);
      expect(repo.bildirimlerimGetir).toHaveBeenCalledWith('k1');
    });
  });

  describe('ekibeGelenBildirimleriGetir', () => {
    it('rolun karsilik geldigi turu bulup repository uzerinden listeler', async () => {
      const repo = repoOlustur({ turIleListele: jest.fn().mockResolvedValue([bildirimOlustur({ tur: 'yangin' })]) });
      const servis = new AcilDurumService(repo, bildirimGonderOlustur(), kullaniciSorgulamaOlustur());

      await servis.ekibeGelenBildirimleriGetir('itfaiye_ekibi');

      expect(repo.turIleListele).toHaveBeenCalledWith('yangin');
    });
  });

  describe('bildirimDurumGuncelle (sahiplik kontrolu)', () => {
    it('bildirim yoksa BildirimBulunamadiException firlatir', async () => {
      const repo = repoOlustur({ bildirimIdIleBul: jest.fn().mockResolvedValue(null) });
      const servis = new AcilDurumService(repo, bildirimGonderOlustur(), kullaniciSorgulamaOlustur());

      await expect(servis.bildirimDurumGuncelle('yok', 'inceleniyor', 'itfaiye_ekibi')).rejects.toBeInstanceOf(
        BildirimBulunamadiException,
      );
    });

    it('baska ekibin bildirimini guncellemeye calisirsa BaskaEkibeAitException firlatir', async () => {
      const repo = repoOlustur({ bildirimIdIleBul: jest.fn().mockResolvedValue(bildirimOlustur({ tur: 'yangin' })) });
      const servis = new AcilDurumService(repo, bildirimGonderOlustur(), kullaniciSorgulamaOlustur());

      await expect(servis.bildirimDurumGuncelle('b1', 'inceleniyor', 'guvenlik_ekibi')).rejects.toBeInstanceOf(
        BaskaEkibeAitException,
      );
    });

    it('kendi ekibinin bildirimini gunceller', async () => {
      const guncellenmisBildirim = bildirimOlustur({ tur: 'yangin', durum: 'inceleniyor' });
      const repo = repoOlustur({
        bildirimIdIleBul: jest.fn().mockResolvedValue(bildirimOlustur({ tur: 'yangin' })),
        bildirimDurumGuncelle: jest.fn().mockResolvedValue(guncellenmisBildirim),
      });
      const servis = new AcilDurumService(repo, bildirimGonderOlustur(), kullaniciSorgulamaOlustur());

      const sonuc = await servis.bildirimDurumGuncelle('b1', 'inceleniyor', 'itfaiye_ekibi');

      expect(sonuc.durum).toBe('inceleniyor');
      expect(repo.bildirimDurumGuncelle).toHaveBeenCalledWith('b1', 'inceleniyor');
    });
  });
});
