import { FavoriService } from './favori.service';
import { FavoriRepository } from '../domain';

function favoriRepoOlustur(overrides?: Partial<FavoriRepository>): FavoriRepository {
  return {
    ekle: jest.fn().mockResolvedValue({ id: 'fav1', kullaniciId: 'k1', hedefTuru: 'ikinci_el', hedefId: 'h1', olusturmaTarihi: new Date() }),
    kaldir: jest.fn().mockResolvedValue(undefined),
    varMi: jest.fn().mockResolvedValue(false),
    kullanicininFavorileri: jest.fn().mockResolvedValue([]),
    sayiGetir: jest.fn().mockResolvedValue(0),
    ...overrides,
  };
}

describe('FavoriService.durumDegistir', () => {
  it('favoride değilse ekler ve favoride:true döner', async () => {
    const repo = favoriRepoOlustur({ varMi: jest.fn().mockResolvedValue(false) });
    const servis = new FavoriService(repo);

    const sonuc = await servis.durumDegistir('k1', 'ikinci_el', 'h1');

    expect(sonuc).toEqual({ favoride: true });
    expect(repo.ekle).toHaveBeenCalledWith('k1', 'ikinci_el', 'h1');
    expect(repo.kaldir).not.toHaveBeenCalled();
  });

  it('zaten favorideyse kaldırır ve favoride:false döner', async () => {
    const repo = favoriRepoOlustur({ varMi: jest.fn().mockResolvedValue(true) });
    const servis = new FavoriService(repo);

    const sonuc = await servis.durumDegistir('k1', 'firma', 'f1');

    expect(sonuc).toEqual({ favoride: false });
    expect(repo.kaldir).toHaveBeenCalledWith('k1', 'firma', 'f1');
    expect(repo.ekle).not.toHaveBeenCalled();
  });
});

describe('FavoriService.favorilerimGetir / sayiGetir', () => {
  it('kullanicininFavorileri repo çağrısını türe göre yapar', async () => {
    const repo = favoriRepoOlustur({ kullanicininFavorileri: jest.fn().mockResolvedValue(['id1', 'id2']) });
    const servis = new FavoriService(repo);

    const sonuc = await servis.favorilerimGetir('k1', 'is_ilani');

    expect(sonuc).toEqual(['id1', 'id2']);
    expect(repo.kullanicininFavorileri).toHaveBeenCalledWith('k1', 'is_ilani');
  });

  it('sayiGetir repo sayacını döner', async () => {
    const repo = favoriRepoOlustur({ sayiGetir: jest.fn().mockResolvedValue(7) });
    const servis = new FavoriService(repo);

    await expect(servis.sayiGetir('is_ilani', 'i1')).resolves.toBe(7);
  });
});
