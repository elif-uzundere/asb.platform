import { IsIlani } from './is-ilani.entity';

describe('IsIlani.yeniIlan', () => {
  it('yeni ilan her zaman "aktif" durumunda başlar, dışarıdan set edilemez', () => {
    const ilan = IsIlani.yeniIlan('i1', 'f1', 'k1', {
      baslik: 'Depo Sorumlusu',
      aciklama: 'Açıklama',
    });

    expect(ilan.durum).toBe('aktif');
  });

  it('konum verilmezse null olur', () => {
    const ilan = IsIlani.yeniIlan('i1', 'f1', 'k1', {
      baslik: 'Depo Sorumlusu',
      aciklama: 'Açıklama',
    });

    expect(ilan.konum).toBeNull();
  });

  it('firmaId ve olusturanKullaniciId aynen taşınır', () => {
    const ilan = IsIlani.yeniIlan('i1', 'f1', 'k1', {
      baslik: 'Depo Sorumlusu',
      aciklama: 'Açıklama',
    });

    expect(ilan.firmaId).toBe('f1');
    expect(ilan.olusturanKullaniciId).toBe('k1');
  });
});

describe('IsIlani.kapatilabilir', () => {
  function ilanOlustur(durum: 'aktif' | 'kapali') {
    return new IsIlani('i1', 'f1', 'k1', 'Başlık', 'Açıklama', null, new Date(), durum);
  }

  it('aktif ilan kapatılabilir', () => {
    expect(ilanOlustur('aktif').kapatilabilir()).toBe(true);
  });

  it('zaten kapalı ilan tekrar kapatılamaz', () => {
    expect(ilanOlustur('kapali').kapatilabilir()).toBe(false);
  });
});
