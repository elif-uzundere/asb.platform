import { IsBasvurusu } from './is-basvurusu.entity';

describe('IsBasvurusu.yeniBasvuru', () => {
  it('yeni başvuru her zaman "beklemede" durumunda başlar', () => {
    const basvuru = IsBasvurusu.yeniBasvuru('b1', 'i1', 'k1');

    expect(basvuru.durum).toBe('beklemede');
  });

  it('isIlaniId ve kullaniciId aynen taşınır', () => {
    const basvuru = IsBasvurusu.yeniBasvuru('b1', 'i1', 'k1');

    expect(basvuru.isIlaniId).toBe('i1');
    expect(basvuru.kullaniciId).toBe('k1');
  });
});
