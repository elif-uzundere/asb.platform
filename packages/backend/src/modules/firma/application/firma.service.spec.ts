import { FirmaService } from './firma.service';
import { Firma, FirmaBulunamadiException, FirmaZatenOnayliException, FirmaRepository } from '../domain';

function firmaOlustur(
  onayDurumu: 'beklemede' | 'onaylandi' | 'reddedildi',
  aktif = true,
): Firma {
  return new Firma(
    'f1',
    'Test A.Ş.',
    null,
    'Kimya',
    'Adres',
    null,
    null,
    onayDurumu,
    aktif,
    null,
    null,
    null,
    new Date(),
  );
}

function repoOlustur(overrides?: Partial<FirmaRepository>): FirmaRepository {
  return {
    listele: jest.fn().mockResolvedValue([]),
    idIleBul: jest.fn().mockResolvedValue(null),
    sektorleriGetir: jest.fn().mockResolvedValue([]),
    olustur: jest.fn(),
    onayBekleyenleriGetir: jest.fn().mockResolvedValue([]),
    onayDurumuGuncelle: jest.fn(),
    ...overrides,
  };
}

describe('FirmaService', () => {
  describe('listele', () => {
    it('repository onaylı döndürse bile ikinci bir emniyet kemeriyle onaysız/pasif olanı süzer', async () => {
      const repo = repoOlustur({
        listele: jest
          .fn()
          .mockResolvedValue([firmaOlustur('onaylandi'), firmaOlustur('beklemede')]),
      });
      const servis = new FirmaService(repo);

      const sonuc = await servis.listele({});

      expect(sonuc).toHaveLength(1);
      expect(sonuc[0].onayDurumu).toBe('onaylandi');
    });
  });

  describe('detay', () => {
    it('firma yoksa FirmaBulunamadiException fırlatır', async () => {
      const servis = new FirmaService(repoOlustur());

      await expect(servis.detay('yok')).rejects.toBeInstanceOf(FirmaBulunamadiException);
    });

    it('onaylanmamış firma için de "bulunamadı" der (varlığını sızdırmaz)', async () => {
      const repo = repoOlustur({
        idIleBul: jest.fn().mockResolvedValue(firmaOlustur('beklemede')),
      });
      const servis = new FirmaService(repo);

      await expect(servis.detay('f1')).rejects.toBeInstanceOf(FirmaBulunamadiException);
    });

    it('onaylı firma detayını döner', async () => {
      const onayli = firmaOlustur('onaylandi');
      const repo = repoOlustur({ idIleBul: jest.fn().mockResolvedValue(onayli) });
      const servis = new FirmaService(repo);

      await expect(servis.detay('f1')).resolves.toBe(onayli);
    });
  });

  describe('olustur (BR-1)', () => {
    it('yeni firma her zaman beklemede durumunda kaydedilir', async () => {
      const repo = repoOlustur({ olustur: jest.fn().mockImplementation((f: Firma) => f) });
      const servis = new FirmaService(repo);

      const sonuc = await servis.olustur({ ad: 'Yeni A.Ş.', sektor: 'Kimya', adres: 'Adres' });

      expect(sonuc.onayDurumu).toBe('beklemede');
      expect(repo.olustur).toHaveBeenCalled();
    });
  });

  describe('onayla', () => {
    it('firma yoksa FirmaBulunamadiException fırlatır', async () => {
      const servis = new FirmaService(repoOlustur());

      await expect(servis.onayla('yok')).rejects.toBeInstanceOf(FirmaBulunamadiException);
    });

    it('zaten onaylı firma tekrar onaylanamaz', async () => {
      const repo = repoOlustur({
        idIleBul: jest.fn().mockResolvedValue(firmaOlustur('onaylandi')),
      });
      const servis = new FirmaService(repo);

      await expect(servis.onayla('f1')).rejects.toBeInstanceOf(FirmaZatenOnayliException);
    });

    it('beklemedeki firmayı onaylar', async () => {
      const repo = repoOlustur({
        idIleBul: jest.fn().mockResolvedValue(firmaOlustur('beklemede')),
        onayDurumuGuncelle: jest.fn().mockResolvedValue(firmaOlustur('onaylandi')),
      });
      const servis = new FirmaService(repo);

      await servis.onayla('f1');

      expect(repo.onayDurumuGuncelle).toHaveBeenCalledWith('f1', 'onaylandi');
    });
  });
});
