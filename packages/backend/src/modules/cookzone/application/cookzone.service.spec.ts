import { CookzoneService } from './cookzone.service';
import {
  CookzoneIsletme,
  CookzoneIsletmeRepository,
  CookzoneMenuOgesi,
  CookzoneSiparis,
  CookzoneSiparisRepository,
  BaskaIsletmeyeAitException,
  BosSepetIleSiparisVerilemezException,
  CookzoneSiparisBulunamadiException,
  GecmisSaateSiparisVerilemezException,
  SiparisIlerletilemezException,
} from '../domain';
import type { BildirimGonderPort } from '../../../shared/infrastructure/bildirim/bildirim-gonder.port';

function menuOgesiOlustur(fiyat = 50): CookzoneMenuOgesi {
  return new CookzoneMenuOgesi('m1', 'i1', 'Test Ürün', null, fiyat, 'Ana Yemek', true);
}

function siparisOlustur(durum: CookzoneSiparis['durum'] = 'beklemede', isletmeId = 'i1'): CookzoneSiparis {
  return new CookzoneSiparis('s1', 'k1', isletmeId, durum, 100, new Date('2099-01-01'), new Date());
}

function isletmeRepoOlustur(overrides?: Partial<CookzoneIsletmeRepository>): CookzoneIsletmeRepository {
  return {
    idIleBul: jest.fn().mockResolvedValue(new CookzoneIsletme('i1', 'Ana Kafeterya', 'b1')),
    tumunuListele: jest.fn().mockResolvedValue([]),
    menuOgeleriGetir: jest.fn().mockResolvedValue([]),
    menuOgesiIdIleBul: jest.fn().mockResolvedValue(menuOgesiOlustur()),
    ...overrides,
  };
}

function siparisRepoOlustur(overrides?: Partial<CookzoneSiparisRepository>): CookzoneSiparisRepository {
  return {
    olustur: jest.fn().mockImplementation((s: CookzoneSiparis) => s),
    idIleBul: jest.fn().mockResolvedValue(null),
    kullaniciyaGoreListele: jest.fn().mockResolvedValue([]),
    isletmeyeGoreListele: jest.fn().mockResolvedValue([]),
    durumGuncelle: jest.fn(),
    kalemleriGetir: jest.fn().mockResolvedValue([]),
    ...overrides,
  };
}

function bildirimOlustur(): BildirimGonderPort {
  return { gonder: jest.fn().mockResolvedValue(undefined) };
}

describe('CookzoneService.siparisOlustur', () => {
  it('bos sepetle siparis verilemez', async () => {
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepoOlustur(), bildirimOlustur());

    await expect(servis.siparisOlustur('k1', 'i1', new Date('2099-01-01'), [])).rejects.toBeInstanceOf(
      BosSepetIleSiparisVerilemezException,
    );
  });

  it('gecmis saate siparis verilemez', async () => {
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepoOlustur(), bildirimOlustur());

    await expect(
      servis.siparisOlustur('k1', 'i1', new Date('2020-01-01'), [{ menuOgesiId: 'm1', adet: 1 }]),
    ).rejects.toBeInstanceOf(GecmisSaateSiparisVerilemezException);
  });

  it('toplam tutar kalemlerden hesaplanir', async () => {
    const isletmeRepo = isletmeRepoOlustur({
      menuOgesiIdIleBul: jest.fn().mockResolvedValue(menuOgesiOlustur(50)),
    });
    const siparisRepo = siparisRepoOlustur({
      olustur: jest.fn().mockImplementation((s: CookzoneSiparis) => s),
    });
    const servis = new CookzoneService(isletmeRepo, siparisRepo, bildirimOlustur());

    const sonuc = await servis.siparisOlustur('k1', 'i1', new Date('2099-01-01'), [
      { menuOgesiId: 'm1', adet: 3 },
    ]);

    expect(sonuc.toplamTutar).toBe(150);
    expect(sonuc.durum).toBe('beklemede');
  });
});

describe('CookzoneService.siparisIlerlet', () => {
  it('siparis yoksa CookzoneSiparisBulunamadiException firlatir', async () => {
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepoOlustur(), bildirimOlustur());

    await expect(servis.siparisIlerlet('yok', 'i1')).rejects.toBeInstanceOf(CookzoneSiparisBulunamadiException);
  });

  it('baska isletmeye ait siparis ilerletilemez', async () => {
    const siparisRepo = siparisRepoOlustur({
      idIleBul: jest.fn().mockResolvedValue(siparisOlustur('beklemede', 'i1')),
    });
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepo, bildirimOlustur());

    await expect(servis.siparisIlerlet('s1', 'baska-isletme')).rejects.toBeInstanceOf(
      BaskaIsletmeyeAitException,
    );
  });

  it('zaten son durumdaki siparis ilerletilemez', async () => {
    const siparisRepo = siparisRepoOlustur({
      idIleBul: jest.fn().mockResolvedValue(siparisOlustur('teslim_edildi', 'i1')),
    });
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepo, bildirimOlustur());

    await expect(servis.siparisIlerlet('s1', 'i1')).rejects.toBeInstanceOf(SiparisIlerletilemezException);
  });

  it('"hazir"a gecerken musteriye bildirim gonderir', async () => {
    const siparisRepo = siparisRepoOlustur({
      idIleBul: jest.fn().mockResolvedValue(siparisOlustur('hazirlaniyor', 'i1')),
      durumGuncelle: jest.fn().mockResolvedValue(siparisOlustur('hazir', 'i1')),
    });
    const bildirim = bildirimOlustur();
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepo, bildirim);

    await servis.siparisIlerlet('s1', 'i1');

    expect(siparisRepo.durumGuncelle).toHaveBeenCalledWith('s1', 'hazir');
    expect(bildirim.gonder).toHaveBeenCalledWith(
      'k1',
      expect.any(String),
      expect.any(String),
      expect.objectContaining({ tur: 'cookzone_siparis' }),
    );
  });

  it('diger gecislerde bildirim GONDERILMEZ', async () => {
    const siparisRepo = siparisRepoOlustur({
      idIleBul: jest.fn().mockResolvedValue(siparisOlustur('beklemede', 'i1')),
      durumGuncelle: jest.fn().mockResolvedValue(siparisOlustur('alindi', 'i1')),
    });
    const bildirim = bildirimOlustur();
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepo, bildirim);

    await servis.siparisIlerlet('s1', 'i1');

    expect(bildirim.gonder).not.toHaveBeenCalled();
  });
});
