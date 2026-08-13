import { CookzoneSiparis } from './cookzone-siparis.entity';

describe('CookzoneSiparis.yeniSiparis', () => {
  it('yeni siparis her zaman "beklemede" durumunda baslar', () => {
    const siparis = CookzoneSiparis.yeniSiparis('s1', 'k1', 'i1', 100, new Date('2026-12-01T12:00:00Z'));

    expect(siparis.durum).toBe('beklemede');
  });
});

describe('CookzoneSiparis.sonrakiDurum / ilerletilebilir', () => {
  function siparisOlustur(durum: CookzoneSiparis['durum']) {
    return new CookzoneSiparis('s1', 'k1', 'i1', durum, 100, new Date(), new Date());
  }

  it('durum sirasi atlanamaz, hep bir sonrakini doner', () => {
    expect(siparisOlustur('beklemede').sonrakiDurum()).toBe('alindi');
    expect(siparisOlustur('alindi').sonrakiDurum()).toBe('hazirlaniyor');
    expect(siparisOlustur('hazirlaniyor').sonrakiDurum()).toBe('hazir');
    expect(siparisOlustur('hazir').sonrakiDurum()).toBe('teslim_edildi');
  });

  it('teslim_edildi sondur, sonraki durum yoktur', () => {
    expect(siparisOlustur('teslim_edildi').sonrakiDurum()).toBeNull();
    expect(siparisOlustur('teslim_edildi').ilerletilebilir()).toBe(false);
  });

  it('son durum disindaki her siparis ilerletilebilir', () => {
    expect(siparisOlustur('beklemede').ilerletilebilir()).toBe(true);
    expect(siparisOlustur('hazir').ilerletilebilir()).toBe(true);
  });
});

describe('CookzoneSiparis.bildirimGerektirir', () => {
  const siparis = new CookzoneSiparis('s1', 'k1', 'i1', 'hazirlaniyor', 100, new Date(), new Date());

  it('sadece "hazir" durumuna gecerken bildirim gerekir', () => {
    expect(siparis.bildirimGerektirir('hazir')).toBe(true);
  });

  it('diger durumlara gecerken bildirim gerekmez', () => {
    expect(siparis.bildirimGerektirir('alindi')).toBe(false);
    expect(siparis.bildirimGerektirir('hazirlaniyor')).toBe(false);
    expect(siparis.bildirimGerektirir('teslim_edildi')).toBe(false);
  });
});
