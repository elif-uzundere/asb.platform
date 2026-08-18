import { IsIlaniService } from './is-ilani.service';
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
import type { BildirimGonderPort } from '../../../shared/infrastructure/bildirim/bildirim-gonder.port';

function ilanOlustur(durum: 'aktif' | 'kapali' = 'aktif', firmaId = 'f1'): IsIlani {
  return new IsIlani('i1', firmaId, 'k1', 'Depo Sorumlusu', 'Açıklama', null, new Date(), durum);
}

function isIlaniRepoOlustur(overrides?: Partial<IsIlaniRepository>): IsIlaniRepository {
  return {
    listele: jest.fn().mockResolvedValue([]),
    idIleBul: jest.fn().mockResolvedValue(null),
    olustur: jest.fn(),
    durumGuncelle: jest.fn(),
    ...overrides,
  };
}

function basvuruRepoOlustur(overrides?: Partial<IsBasvurusuRepository>): IsBasvurusuRepository {
  return {
    olustur: jest.fn(),
    ilanaGoreListele: jest.fn().mockResolvedValue([]),
    kullaniciVeIlanaGoreBul: jest.fn().mockResolvedValue(null),
    kullaniciyaGoreListele: jest.fn().mockResolvedValue([]),
    idIleBul: jest.fn().mockResolvedValue(null),
    durumGuncelle: jest.fn(),
    ...overrides,
  };
}

function firmaSorgulamaOlustur(overrides?: Partial<FirmaSorgulamaPort>): FirmaSorgulamaPort {
  return {
    isOnayli: jest.fn().mockResolvedValue(true),
    adiGetir: jest.fn().mockResolvedValue('Test A.Ş.'),
    ...overrides,
  };
}

function bildirimGonderOlustur(overrides?: Partial<BildirimGonderPort>): BildirimGonderPort {
  return {
    gonder: jest.fn().mockResolvedValue(undefined),
    ...overrides,
  };
}

describe('IsIlaniService', () => {
  describe('detay', () => {
    it('ilan yoksa IsIlaniBulunamadiException fırlatır', async () => {
      const servis = new IsIlaniService(isIlaniRepoOlustur(), basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(servis.detay('yok')).rejects.toBeInstanceOf(IsIlaniBulunamadiException);
    });

    it('ilan bulunursa döner', async () => {
      const ilan = ilanOlustur();
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilan) });
      const servis = new IsIlaniService(repo, basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(servis.detay('i1')).resolves.toBe(ilan);
    });
  });

  describe('olustur (BR-2)', () => {
    it('firma onaylı değilse FirmaOnayliDegilException fırlatır', async () => {
      const firmaSorgulama = firmaSorgulamaOlustur({ isOnayli: jest.fn().mockResolvedValue(false) });
      const servis = new IsIlaniService(isIlaniRepoOlustur(), basvuruRepoOlustur(), firmaSorgulama, bildirimGonderOlustur());

      await expect(
        servis.olustur('f1', 'k1', { baslik: 'Başlık', aciklama: 'Açıklama' }),
      ).rejects.toBeInstanceOf(FirmaOnayliDegilException);
    });

    it('firma onaylıysa aktif durumda ilan oluşturur', async () => {
      const repo = isIlaniRepoOlustur({ olustur: jest.fn().mockImplementation((i: IsIlani) => i) });
      const servis = new IsIlaniService(repo, basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      const sonuc = await servis.olustur('f1', 'k1', { baslik: 'Başlık', aciklama: 'Açıklama' });

      expect(sonuc.durum).toBe('aktif');
      expect(repo.olustur).toHaveBeenCalled();
    });
  });

  describe('kapat (sahiplik kontrolü)', () => {
    it('ilan yoksa IsIlaniBulunamadiException fırlatır', async () => {
      const servis = new IsIlaniService(isIlaniRepoOlustur(), basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(servis.kapat('yok', 'f1')).rejects.toBeInstanceOf(IsIlaniBulunamadiException);
    });

    it('başka firmaya ait ilanı kapatmaya çalışırsa BaskaFirmayaAitException fırlatır', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif', 'f1')) });
      const servis = new IsIlaniService(repo, basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(servis.kapat('i1', 'baska-firma')).rejects.toBeInstanceOf(BaskaFirmayaAitException);
    });

    it('zaten kapalı ilanı tekrar kapatmaya çalışırsa IlanKapaliException fırlatır', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('kapali', 'f1')) });
      const servis = new IsIlaniService(repo, basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(servis.kapat('i1', 'f1')).rejects.toBeInstanceOf(IlanKapaliException);
    });

    it('sahibi olunan aktif ilanı kapatır', async () => {
      const repo = isIlaniRepoOlustur({
        idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif', 'f1')),
        durumGuncelle: jest.fn().mockResolvedValue(ilanOlustur('kapali', 'f1')),
      });
      const servis = new IsIlaniService(repo, basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await servis.kapat('i1', 'f1');

      expect(repo.durumGuncelle).toHaveBeenCalledWith('i1', 'kapali');
    });
  });

  describe('basvurulariGetir (sahiplik kontrolü)', () => {
    it('başka firmaya ait ilanın başvurularını görmeye çalışırsa BaskaFirmayaAitException fırlatır', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif', 'f1')) });
      const servis = new IsIlaniService(repo, basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(servis.basvurulariGetir('i1', 'baska-firma')).rejects.toBeInstanceOf(
        BaskaFirmayaAitException,
      );
    });
  });

  describe('basvur', () => {
    it('ilan yoksa IsIlaniBulunamadiException fırlatır', async () => {
      const servis = new IsIlaniService(isIlaniRepoOlustur(), basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(servis.basvur('yok', 'k1')).rejects.toBeInstanceOf(IsIlaniBulunamadiException);
    });

    it('kapalı ilana başvurmaya çalışırsa IlanKapaliException fırlatır', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('kapali')) });
      const servis = new IsIlaniService(repo, basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(servis.basvur('i1', 'k1')).rejects.toBeInstanceOf(IlanKapaliException);
    });

    it('aynı kullanıcı aynı ilana ikinci kez başvuramaz', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif')) });
      const basvuruRepo = basvuruRepoOlustur({
        kullaniciVeIlanaGoreBul: jest.fn().mockResolvedValue(IsBasvurusu.yeniBasvuru('b1', 'i1', 'k1')),
      });
      const servis = new IsIlaniService(repo, basvuruRepo, firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(servis.basvur('i1', 'k1')).rejects.toBeInstanceOf(ZatenBasvurulduException);
    });

    it('aktif ilana ilk başvuru başarıyla oluşturulur', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif')) });
      const basvuruRepo = basvuruRepoOlustur({
        olustur: jest.fn().mockImplementation((b: IsBasvurusu) => b),
      });
      const servis = new IsIlaniService(repo, basvuruRepo, firmaSorgulamaOlustur(), bildirimGonderOlustur());

      const sonuc = await servis.basvur('i1', 'k1');

      expect(sonuc.durum).toBe('beklemede');
      expect(basvuruRepo.olustur).toHaveBeenCalled();
    });

    it('basvuru gelince ilani acan kisiye bildirim gonderir', async () => {
      // ilanOlustur() ilani 'k1' kullanicisinin actigini varsayiyor (bkz. helper).
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif')) });
      const basvuruRepo = basvuruRepoOlustur({
        olustur: jest.fn().mockImplementation((b: IsBasvurusu) => b),
      });
      const bildirimGonder = bildirimGonderOlustur();
      const servis = new IsIlaniService(repo, basvuruRepo, firmaSorgulamaOlustur(), bildirimGonder);

      await servis.basvur('i1', 'aday1');

      expect(bildirimGonder.gonder).toHaveBeenCalledWith(
        'k1',
        expect.any(String),
        expect.any(String),
        expect.any(Object),
      );
    });
  });

  describe('basvuruDurumGuncelle (sahiplik kontrolü)', () => {
    it('başka firmaya ait ilanın başvurusunu güncellemeye çalışırsa BaskaFirmayaAitException fırlatır', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif', 'f1')) });
      const servis = new IsIlaniService(repo, basvuruRepoOlustur(), firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(
        servis.basvuruDurumGuncelle('i1', 'b1', 'baska-firma', { durum: 'kabul' }),
      ).rejects.toBeInstanceOf(BaskaFirmayaAitException);
    });

    it('başvuru bulunamazsa BasvuruBulunamadiException fırlatır', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif', 'f1')) });
      const basvuruRepo = basvuruRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(null) });
      const servis = new IsIlaniService(repo, basvuruRepo, firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(
        servis.basvuruDurumGuncelle('i1', 'yok', 'f1', { durum: 'kabul' }),
      ).rejects.toBeInstanceOf(BasvuruBulunamadiException);
    });

    it('başvuru başka bir ilana aitse BasvuruBulunamadiException fırlatır', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif', 'f1')) });
      const basvuruRepo = basvuruRepoOlustur({
        idIleBul: jest.fn().mockResolvedValue(IsBasvurusu.yeniBasvuru('b1', 'baska-ilan', 'k1')),
      });
      const servis = new IsIlaniService(repo, basvuruRepo, firmaSorgulamaOlustur(), bildirimGonderOlustur());

      await expect(
        servis.basvuruDurumGuncelle('i1', 'b1', 'f1', { durum: 'kabul' }),
      ).rejects.toBeInstanceOf(BasvuruBulunamadiException);
    });

    it('sahibi olunan ilanın başvurusunu günceller', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif', 'f1')) });
      const basvuruRepo = basvuruRepoOlustur({
        idIleBul: jest.fn().mockResolvedValue(IsBasvurusu.yeniBasvuru('b1', 'i1', 'k1')),
        durumGuncelle: jest.fn().mockImplementation((id: string, durum) => new IsBasvurusu(id, 'i1', 'k1', new Date(), durum)),
      });
      const servis = new IsIlaniService(repo, basvuruRepo, firmaSorgulamaOlustur(), bildirimGonderOlustur());

      const sonuc = await servis.basvuruDurumGuncelle('i1', 'b1', 'f1', { durum: 'kabul' });

      expect(sonuc.durum).toBe('kabul');
      expect(basvuruRepo.durumGuncelle).toHaveBeenCalledWith('b1', 'kabul');
    });

    it('durum degisince basvuru sahibine bildirim gonderir', async () => {
      const repo = isIlaniRepoOlustur({ idIleBul: jest.fn().mockResolvedValue(ilanOlustur('aktif', 'f1')) });
      const basvuruRepo = basvuruRepoOlustur({
        idIleBul: jest.fn().mockResolvedValue(IsBasvurusu.yeniBasvuru('b1', 'i1', 'aday1')),
        durumGuncelle: jest.fn().mockImplementation((id: string, durum) => new IsBasvurusu(id, 'i1', 'aday1', new Date(), durum)),
      });
      const bildirimGonder = bildirimGonderOlustur();
      const servis = new IsIlaniService(repo, basvuruRepo, firmaSorgulamaOlustur(), bildirimGonder);

      await servis.basvuruDurumGuncelle('i1', 'b1', 'f1', { durum: 'kabul' });

      expect(bildirimGonder.gonder).toHaveBeenCalledWith(
        'aday1',
        expect.any(String),
        expect.any(String),
        expect.any(Object),
      );
    });
  });

  describe('basvurularim', () => {
    it('kullanicinin kendi basvurularini repository uzerinden doner', async () => {
      const kendiBasvurusu = IsBasvurusu.yeniBasvuru('b1', 'i1', 'k1');
      const basvuruRepo = basvuruRepoOlustur({
        kullaniciyaGoreListele: jest.fn().mockResolvedValue([kendiBasvurusu]),
      });
      const servis = new IsIlaniService(isIlaniRepoOlustur(), basvuruRepo, firmaSorgulamaOlustur(), bildirimGonderOlustur());

      const sonuc = await servis.basvurularim('k1');

      expect(sonuc).toEqual([kendiBasvurusu]);
      expect(basvuruRepo.kullaniciyaGoreListele).toHaveBeenCalledWith('k1');
    });
  });
});
