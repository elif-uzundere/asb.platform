import { CookzoneService } from './cookzone.service';
import {
  CookzoneIsletme,
  CookzoneIsletmeRepository,
  CookzoneMenuOgesi,
  CookzoneSiparis,
  CookzoneSiparisRepository,
  BaskaIsletmeninMenuOgesiException,
  BaskaIsletmeyeAitException,
  BosSepetIleSiparisVerilemezException,
  CookzoneSiparisBulunamadiException,
  GecmisSaateSiparisVerilemezException,
  SiparisIlerletilemezException,
} from '../domain';
import type { BildirimGonderPort } from '../../../shared/infrastructure/bildirim/bildirim-gonder.port';
import type { KullaniciSorgulamaPort } from '../../auth/adapters/public/kullanici-sorgulama.port';

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
    menuOgeleriTumunuGetir: jest.fn().mockResolvedValue([]),
    menuOgesiIdIleBul: jest.fn().mockResolvedValue(menuOgesiOlustur()),
    menuOgesiOlustur: jest.fn().mockResolvedValue(menuOgesiOlustur()),
    menuOgesiGuncelle: jest.fn().mockResolvedValue(menuOgesiOlustur()),
    menuOgesiSil: jest.fn().mockResolvedValue(undefined),
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

function kullaniciSorgulamaOlustur(overrides?: Partial<KullaniciSorgulamaPort>): KullaniciSorgulamaPort {
  return {
    adSoyadGetir: jest.fn().mockResolvedValue('Test Kullanıcı'),
    rolIleKullanicilariGetir: jest.fn().mockResolvedValue([]),
    cookzoneIsletmesineGoreKullanicilariGetir: jest.fn().mockResolvedValue([]),
    ...overrides,
  };
}

describe('CookzoneService.siparisOlustur', () => {
  it('bos sepetle siparis verilemez', async () => {
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepoOlustur(), bildirimOlustur(), kullaniciSorgulamaOlustur());

    await expect(servis.siparisOlustur('k1', 'i1', new Date('2099-01-01'), [])).rejects.toBeInstanceOf(
      BosSepetIleSiparisVerilemezException,
    );
  });

  it('gecmis saate siparis verilemez', async () => {
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepoOlustur(), bildirimOlustur(), kullaniciSorgulamaOlustur());

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
    const servis = new CookzoneService(isletmeRepo, siparisRepo, bildirimOlustur(), kullaniciSorgulamaOlustur());

    const sonuc = await servis.siparisOlustur('k1', 'i1', new Date('2099-01-01'), [
      { menuOgesiId: 'm1', adet: 3 },
    ]);

    expect(sonuc.toplamTutar).toBe(150);
    expect(sonuc.durum).toBe('beklemede');
  });

  it('yeni siparis gelince isletmeye bagli yetkiliye bildirim gonderir', async () => {
    const siparisRepo = siparisRepoOlustur({
      olustur: jest.fn().mockImplementation((s: CookzoneSiparis) => s),
    });
    const bildirim = bildirimOlustur();
    const kullaniciSorgulama = kullaniciSorgulamaOlustur({
      cookzoneIsletmesineGoreKullanicilariGetir: jest.fn().mockResolvedValue([{ id: 'yetkili1', adSoyad: 'Test Yetkili' }]),
    });
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepo, bildirim, kullaniciSorgulama);

    await servis.siparisOlustur('k1', 'i1', new Date('2099-01-01'), [{ menuOgesiId: 'm1', adet: 1 }]);

    expect(kullaniciSorgulama.cookzoneIsletmesineGoreKullanicilariGetir).toHaveBeenCalledWith('i1');
    expect(bildirim.gonder).toHaveBeenCalledWith('yetkili1', expect.any(String), expect.any(String), expect.any(Object));
  });
});

describe('CookzoneService.siparisIlerlet', () => {
  it('siparis yoksa CookzoneSiparisBulunamadiException firlatir', async () => {
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepoOlustur(), bildirimOlustur(), kullaniciSorgulamaOlustur());

    await expect(servis.siparisIlerlet('yok', 'i1')).rejects.toBeInstanceOf(CookzoneSiparisBulunamadiException);
  });

  it('baska isletmeye ait siparis ilerletilemez', async () => {
    const siparisRepo = siparisRepoOlustur({
      idIleBul: jest.fn().mockResolvedValue(siparisOlustur('beklemede', 'i1')),
    });
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepo, bildirimOlustur(), kullaniciSorgulamaOlustur());

    await expect(servis.siparisIlerlet('s1', 'baska-isletme')).rejects.toBeInstanceOf(
      BaskaIsletmeyeAitException,
    );
  });

  it('zaten son durumdaki siparis ilerletilemez', async () => {
    const siparisRepo = siparisRepoOlustur({
      idIleBul: jest.fn().mockResolvedValue(siparisOlustur('teslim_edildi', 'i1')),
    });
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepo, bildirimOlustur(), kullaniciSorgulamaOlustur());

    await expect(servis.siparisIlerlet('s1', 'i1')).rejects.toBeInstanceOf(SiparisIlerletilemezException);
  });

  it('"hazir"a gecerken musteriye bildirim gonderir', async () => {
    const siparisRepo = siparisRepoOlustur({
      idIleBul: jest.fn().mockResolvedValue(siparisOlustur('hazirlaniyor', 'i1')),
      durumGuncelle: jest.fn().mockResolvedValue(siparisOlustur('hazir', 'i1')),
    });
    const bildirim = bildirimOlustur();
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepo, bildirim, kullaniciSorgulamaOlustur());

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
    const servis = new CookzoneService(isletmeRepoOlustur(), siparisRepo, bildirim, kullaniciSorgulamaOlustur());

    await servis.siparisIlerlet('s1', 'i1');

    expect(bildirim.gonder).not.toHaveBeenCalled();
  });
});

describe('CookzoneService.menuOgesiGuncelle / menuOgesiSil', () => {
  it('baska isletmenin menu ogesini guncellemeye calisirsa BaskaIsletmeninMenuOgesiException firlatir', async () => {
    const isletmeRepo = isletmeRepoOlustur({
      menuOgesiIdIleBul: jest.fn().mockResolvedValue(menuOgesiOlustur()),
    });
    const servis = new CookzoneService(isletmeRepo, siparisRepoOlustur(), bildirimOlustur(), kullaniciSorgulamaOlustur());

    await expect(
      servis.menuOgesiGuncelle('m1', 'baska-isletme', { ad: 'Yeni Ad' }),
    ).rejects.toBeInstanceOf(BaskaIsletmeninMenuOgesiException);
  });

  it('baska isletmenin menu ogesini silmeye calisirsa BaskaIsletmeninMenuOgesiException firlatir', async () => {
    const isletmeRepo = isletmeRepoOlustur({
      menuOgesiIdIleBul: jest.fn().mockResolvedValue(menuOgesiOlustur()),
    });
    const servis = new CookzoneService(isletmeRepo, siparisRepoOlustur(), bildirimOlustur(), kullaniciSorgulamaOlustur());

    await expect(servis.menuOgesiSil('m1', 'baska-isletme')).rejects.toBeInstanceOf(
      BaskaIsletmeninMenuOgesiException,
    );
  });

  it('kendi isletmesinin menu ogesini gunceller', async () => {
    const guncellenmisOge = menuOgesiOlustur(75);
    const isletmeRepo = isletmeRepoOlustur({
      menuOgesiIdIleBul: jest.fn().mockResolvedValue(menuOgesiOlustur()),
      menuOgesiGuncelle: jest.fn().mockResolvedValue(guncellenmisOge),
    });
    const servis = new CookzoneService(isletmeRepo, siparisRepoOlustur(), bildirimOlustur(), kullaniciSorgulamaOlustur());

    const sonuc = await servis.menuOgesiGuncelle('m1', 'i1', { fiyat: 75 });

    expect(sonuc.fiyat).toBe(75);
    expect(isletmeRepo.menuOgesiGuncelle).toHaveBeenCalledWith('m1', { fiyat: 75 });
  });
});
