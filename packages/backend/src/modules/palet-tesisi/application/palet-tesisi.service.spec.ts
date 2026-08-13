import { PaletTesisiService } from './palet-tesisi.service';
import { Palet, PaletBulunamadiException, PaletTesisiRepository } from '../domain';

function paletOlustur(overrides?: Partial<Palet>): Palet {
  return {
    id: 'p1',
    ad: 'Standart Euro Palet',
    aciklama: null,
    olcu: null,
    gorselUrl: null,
    aktif: true,
    sira: 1,
    ...overrides,
  };
}

function repoOlustur(overrides?: Partial<PaletTesisiRepository>): PaletTesisiRepository {
  return {
    tesisBilgisiGetir: jest.fn().mockResolvedValue(null),
    paletleriGetir: jest.fn().mockResolvedValue([]),
    tumPaletleriGetir: jest.fn().mockResolvedValue([]),
    paletIdIleBul: jest.fn().mockResolvedValue(null),
    paletOlustur: jest.fn(),
    paletGuncelle: jest.fn(),
    ...overrides,
  };
}

describe('PaletTesisiService', () => {
  describe('paletOlustur', () => {
    it('repository araciligiyla yeni palet olusturur', async () => {
      const yeniPalet = paletOlustur();
      const repo = repoOlustur({ paletOlustur: jest.fn().mockResolvedValue(yeniPalet) });
      const servis = new PaletTesisiService(repo);

      const sonuc = await servis.paletOlustur({
        ad: 'Standart Euro Palet',
        aciklama: null,
        olcu: null,
        gorselUrl: null,
      });

      expect(sonuc).toBe(yeniPalet);
      expect(repo.paletOlustur).toHaveBeenCalled();
    });
  });

  describe('paletGuncelle', () => {
    it('palet yoksa PaletBulunamadiException firlatir', async () => {
      const repo = repoOlustur({ paletIdIleBul: jest.fn().mockResolvedValue(null) });
      const servis = new PaletTesisiService(repo);

      await expect(servis.paletGuncelle('yok', { gorselUrl: '/uploads/x.png' })).rejects.toBeInstanceOf(
        PaletBulunamadiException,
      );
    });

    it('mevcut paleti gunceller', async () => {
      const mevcutPalet = paletOlustur();
      const guncellenmisPalet = paletOlustur({ gorselUrl: '/uploads/x.png' });
      const repo = repoOlustur({
        paletIdIleBul: jest.fn().mockResolvedValue(mevcutPalet),
        paletGuncelle: jest.fn().mockResolvedValue(guncellenmisPalet),
      });
      const servis = new PaletTesisiService(repo);

      const sonuc = await servis.paletGuncelle('p1', { gorselUrl: '/uploads/x.png' });

      expect(sonuc.gorselUrl).toBe('/uploads/x.png');
      expect(repo.paletGuncelle).toHaveBeenCalledWith('p1', { gorselUrl: '/uploads/x.png' });
    });
  });
});
