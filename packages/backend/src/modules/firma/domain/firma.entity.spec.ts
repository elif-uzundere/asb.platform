// Firma entity'sindeki iş kurallarının (BR-1, görünürlük, onay state
// machine) testi — saf domain, hiçbir mock/Nest gerekmiyor.

import { Firma } from './firma.entity';

describe('Firma.yeniKayit (BR-1)', () => {
  it('yeni kayıt her zaman "beklemede" durumunda başlar, dışarıdan set edilemez', () => {
    const firma = Firma.yeniKayit('f1', {
      ad: 'Test A.Ş.',
      sektor: 'Kimya',
      adres: 'Adres',
    });

    expect(firma.onayDurumu).toBe('beklemede');
  });

  it('opsiyonel alanlar verilmezse null/varsayılan olur', () => {
    const firma = Firma.yeniKayit('f1', {
      ad: 'Test A.Ş.',
      sektor: 'Kimya',
      adres: 'Adres',
    });

    expect(firma.logoUrl).toBeNull();
    expect(firma.telefon).toBeNull();
    expect(firma.webAdres).toBeNull();
    expect(firma.kurulusTarihi).toBeNull();
    expect(firma.personelSayisi).toBeNull();
    expect(firma.aktif).toBe(true);
  });
});

describe('Firma.goruntulenebilir', () => {
  function firmaOlustur(onayDurumu: 'beklemede' | 'onaylandi' | 'reddedildi', aktif = true) {
    return new Firma(
      'f1',
      'Test',
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

  it('onaylı ve aktif firma görüntülenebilir', () => {
    expect(firmaOlustur('onaylandi', true).goruntulenebilir()).toBe(true);
  });

  it('beklemede olan firma görüntülenemez', () => {
    expect(firmaOlustur('beklemede', true).goruntulenebilir()).toBe(false);
  });

  it('reddedilen firma görüntülenemez', () => {
    expect(firmaOlustur('reddedildi', true).goruntulenebilir()).toBe(false);
  });

  it('onaylı ama pasifleştirilmiş firma görüntülenemez', () => {
    expect(firmaOlustur('onaylandi', false).goruntulenebilir()).toBe(false);
  });
});

describe('Firma.onaylanabilir', () => {
  function firmaOlustur(onayDurumu: 'beklemede' | 'onaylandi' | 'reddedildi') {
    return new Firma(
      'f1',
      'Test',
      null,
      'Kimya',
      'Adres',
      null,
      null,
      onayDurumu,
      true,
      null,
      null,
      null,
      new Date(),
    );
  }

  it('beklemede olan onaylanabilir', () => {
    expect(firmaOlustur('beklemede').onaylanabilir()).toBe(true);
  });

  it('reddedilen tekrar onaylanabilir (admin kararını değiştirebilir)', () => {
    expect(firmaOlustur('reddedildi').onaylanabilir()).toBe(true);
  });

  it('zaten onaylı olan tekrar onaylanamaz', () => {
    expect(firmaOlustur('onaylandi').onaylanabilir()).toBe(false);
  });
});
