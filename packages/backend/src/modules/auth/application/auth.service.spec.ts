// AuthService'in iş kurallarının testi. jwt-auth.guard.spec.ts ile AYNI
// desen: Nest'i ayağa kaldırmadan, port'ları elle sahteleyerek test ediyoruz
// — hexagonal mimarinin "framework'süz test edilebilirlik" vaadi budur.

import { AuthService } from './auth.service';
import {
  Email,
  Kullanici,
  KullaniciRepository,
  SifreHashPort,
  TokenUreticiPort,
  EmailGonderPort,
  GoogleTokenDogrulayiciPort,
  EmailZatenKayitliException,
  GecersizKimlikBilgisiException,
  GecersizSifirlamaTokenException,
  MevcutSifreYanlisException,
  SifresizHesapException,
} from '../domain';

function sahteKullanici(sifreHash: string | null = 'hash123'): Kullanici {
  return new Kullanici(
    'k1',
    new Email('elif@example.com'),
    sifreHash,
    'Elif',
    'Uzundere',
    'ziyaretci',
    null,
    false,
    null,
  );
}

function servisiOlustur(overrides?: {
  kullaniciRepo?: Partial<KullaniciRepository>;
  sifreHash?: Partial<SifreHashPort>;
  tokenUretici?: Partial<TokenUreticiPort>;
  emailGonderici?: Partial<EmailGonderPort>;
  googleDogrulayici?: Partial<GoogleTokenDogrulayiciPort>;
}) {
  const kullaniciRepo: KullaniciRepository = {
    emailIleBul: jest.fn().mockResolvedValue(null),
    idIleBul: jest.fn().mockResolvedValue(null),
    kaydet: jest.fn().mockImplementation((k: Kullanici) => Promise.resolve(k)),
    sifreGuncelle: jest.fn().mockResolvedValue(undefined),
    epostaGuncelle: jest.fn().mockResolvedValue(undefined),
    profilGuncelle: jest.fn(),
    ...overrides?.kullaniciRepo,
  };
  const sifreHash: SifreHashPort = {
    hashle: jest.fn().mockResolvedValue('yeni-hash'),
    dogrula: jest.fn().mockResolvedValue(true),
    ...overrides?.sifreHash,
  };
  const tokenUretici: TokenUreticiPort = {
    uret: jest.fn().mockResolvedValue('jwt-token'),
    sifirlamaTokenUret: jest.fn().mockResolvedValue('reset-token'),
    sifirlamaTokenDogrula: jest.fn().mockResolvedValue('k1'),
    ...overrides?.tokenUretici,
  };
  const emailGonderici: EmailGonderPort = {
    gonder: jest.fn().mockResolvedValue(undefined),
    ...overrides?.emailGonderici,
  };
  const googleDogrulayici: GoogleTokenDogrulayiciPort = {
    dogrula: jest.fn().mockResolvedValue({
      email: 'google@example.com',
      ad: 'Google',
      soyad: 'Kullanici',
    }),
    ...overrides?.googleDogrulayici,
  };

  const servis = new AuthService(
    kullaniciRepo,
    sifreHash,
    tokenUretici,
    emailGonderici,
    googleDogrulayici,
    'http://localhost:8081/sifre-sifirla',
  );

  return { servis, kullaniciRepo, sifreHash, tokenUretici, emailGonderici, googleDogrulayici };
}

describe('AuthService', () => {
  describe('kayitOl', () => {
    it('e-posta zaten kayıtlıysa reddeder', async () => {
      const { servis } = servisiOlustur({
        kullaniciRepo: { emailIleBul: jest.fn().mockResolvedValue(sahteKullanici()) },
      });

      await expect(
        servis.kayitOl({ ad: 'A', soyad: 'B', email: 'elif@example.com', sifre: 'sifre1234' }),
      ).rejects.toBeInstanceOf(EmailZatenKayitliException);
    });

    it('yeni kullanıcıyı hash\'lenmiş şifreyle kaydeder ve token döner', async () => {
      const { servis, kullaniciRepo, sifreHash } = servisiOlustur();

      const sonuc = await servis.kayitOl({
        ad: 'A',
        soyad: 'B',
        email: 'yeni@example.com',
        sifre: 'sifre1234',
        telefon: '5551112233',
      });

      expect(sifreHash.hashle).toHaveBeenCalledWith('sifre1234');
      expect(kullaniciRepo.kaydet).toHaveBeenCalled();
      expect(sonuc.accessToken).toBe('jwt-token');
      expect(sonuc.kullanici.email).toBe('yeni@example.com');
      expect(sonuc.kullanici.telefon).toBe('5551112233');
    });
  });

  describe('girisYap', () => {
    it('kullanıcı bulunamazsa "hatalı bilgi" hatası verir (hangi alan olduğunu söylemez)', async () => {
      const { servis } = servisiOlustur();

      await expect(
        servis.girisYap({ email: 'yok@example.com', sifre: 'sifre1234' }),
      ).rejects.toBeInstanceOf(GecersizKimlikBilgisiException);
    });

    it('şifresiz (Google) hesaba şifreyle giriş denemesi reddedilir', async () => {
      const { servis } = servisiOlustur({
        kullaniciRepo: { emailIleBul: jest.fn().mockResolvedValue(sahteKullanici(null)) },
      });

      await expect(
        servis.girisYap({ email: 'elif@example.com', sifre: 'herhangi' }),
      ).rejects.toBeInstanceOf(GecersizKimlikBilgisiException);
    });

    it('yanlış şifrede reddeder', async () => {
      const { servis } = servisiOlustur({
        kullaniciRepo: { emailIleBul: jest.fn().mockResolvedValue(sahteKullanici()) },
        sifreHash: { dogrula: jest.fn().mockResolvedValue(false) },
      });

      await expect(
        servis.girisYap({ email: 'elif@example.com', sifre: 'yanlis' }),
      ).rejects.toBeInstanceOf(GecersizKimlikBilgisiException);
    });

    it('doğru bilgilerle token döner', async () => {
      const { servis, tokenUretici } = servisiOlustur({
        kullaniciRepo: { emailIleBul: jest.fn().mockResolvedValue(sahteKullanici()) },
      });

      const sonuc = await servis.girisYap({
        email: 'elif@example.com',
        sifre: 'dogru',
        beniHatirla: true,
      });

      expect(tokenUretici.uret).toHaveBeenCalledWith(expect.anything(), true);
      expect(sonuc.accessToken).toBe('jwt-token');
    });
  });

  describe('googleIleGirisYap', () => {
    it('hesap yoksa şifresiz ve e-postası doğrulanmış olarak otomatik açar', async () => {
      const { servis, kullaniciRepo } = servisiOlustur();

      const sonuc = await servis.googleIleGirisYap('gecerli-id-token');

      expect(kullaniciRepo.kaydet).toHaveBeenCalledWith(
        expect.objectContaining({ sifreHash: null, epostaDogrulandi: true }),
      );
      expect(sonuc.kullanici.email).toBe('google@example.com');
    });

    it('hesap zaten varsa yeni kayıt açmadan giriş yaptırır', async () => {
      const mevcut = sahteKullanici();
      const { servis, kullaniciRepo } = servisiOlustur({
        kullaniciRepo: { emailIleBul: jest.fn().mockResolvedValue(mevcut) },
        googleDogrulayici: {
          dogrula: jest.fn().mockResolvedValue({
            email: 'elif@example.com',
            ad: 'Elif',
            soyad: 'Uzundere',
          }),
        },
      });

      await servis.googleIleGirisYap('gecerli-id-token');

      expect(kullaniciRepo.kaydet).not.toHaveBeenCalled();
    });
  });

  describe('sifreDegistir', () => {
    it('şifresiz (Google) hesapta reddeder', async () => {
      const { servis } = servisiOlustur({
        kullaniciRepo: { idIleBul: jest.fn().mockResolvedValue(sahteKullanici(null)) },
      });

      await expect(
        servis.sifreDegistir('k1', { mevcutSifre: 'x', yeniSifre: 'yeniSifre123' }),
      ).rejects.toBeInstanceOf(SifresizHesapException);
    });

    it('mevcut şifre yanlışsa reddeder', async () => {
      const { servis } = servisiOlustur({
        kullaniciRepo: { idIleBul: jest.fn().mockResolvedValue(sahteKullanici()) },
        sifreHash: { dogrula: jest.fn().mockResolvedValue(false) },
      });

      await expect(
        servis.sifreDegistir('k1', { mevcutSifre: 'yanlis', yeniSifre: 'yeniSifre123' }),
      ).rejects.toBeInstanceOf(MevcutSifreYanlisException);
    });

    it('doğru mevcut şifreyle günceller', async () => {
      const { servis, kullaniciRepo, sifreHash } = servisiOlustur({
        kullaniciRepo: { idIleBul: jest.fn().mockResolvedValue(sahteKullanici()) },
      });

      await servis.sifreDegistir('k1', { mevcutSifre: 'dogru', yeniSifre: 'yeniSifre123' });

      expect(sifreHash.hashle).toHaveBeenCalledWith('yeniSifre123');
      expect(kullaniciRepo.sifreGuncelle).toHaveBeenCalledWith('k1', 'yeni-hash');
    });
  });

  describe('epostaDegistir', () => {
    it('yeni e-posta başkasına aitse reddeder', async () => {
      const baskasi = new Kullanici(
        'k2',
        new Email('baskasi@example.com'),
        'hash',
        'B',
        'K',
        'ziyaretci',
        null,
        false,
        null,
      );
      const { servis } = servisiOlustur({
        kullaniciRepo: {
          idIleBul: jest.fn().mockResolvedValue(sahteKullanici()),
          emailIleBul: jest.fn().mockResolvedValue(baskasi),
        },
      });

      await expect(
        servis.epostaDegistir('k1', {
          yeniEposta: 'baskasi@example.com',
          mevcutSifre: 'dogru',
        }),
      ).rejects.toBeInstanceOf(EmailZatenKayitliException);
    });

    it('kendi mevcut e-postasına "değiştirmek" başkasına ait sayılmaz', async () => {
      const kendisi = sahteKullanici();
      const { servis, kullaniciRepo } = servisiOlustur({
        kullaniciRepo: {
          idIleBul: jest.fn().mockResolvedValue(kendisi),
          emailIleBul: jest.fn().mockResolvedValue(kendisi),
        },
      });

      await servis.epostaDegistir('k1', {
        yeniEposta: 'elif@example.com',
        mevcutSifre: 'dogru',
      });

      expect(kullaniciRepo.epostaGuncelle).toHaveBeenCalledWith('k1', 'elif@example.com');
    });
  });

  describe('sifreSifirla', () => {
    it('geçersiz token reddeder', async () => {
      const { servis } = servisiOlustur({
        tokenUretici: { sifirlamaTokenDogrula: jest.fn().mockResolvedValue(null) },
      });

      await expect(
        servis.sifreSifirla({ token: 'gecersiz', yeniSifre: 'yeniSifre123' }),
      ).rejects.toBeInstanceOf(GecersizSifirlamaTokenException);
    });

    it('geçerli tokende şifreyi günceller', async () => {
      const { servis, kullaniciRepo } = servisiOlustur();

      await servis.sifreSifirla({ token: 'gecerli', yeniSifre: 'yeniSifre123' });

      expect(kullaniciRepo.sifreGuncelle).toHaveBeenCalledWith('k1', 'yeni-hash');
    });
  });

  describe('sifremiUnuttum', () => {
    it('kayıtlı olmayan e-postada sessizce çıkar (e-posta enumeration önlemi)', async () => {
      const { servis, emailGonderici } = servisiOlustur();

      await servis.sifremiUnuttum({ email: 'yok@example.com' });

      expect(emailGonderici.gonder).not.toHaveBeenCalled();
    });

    it('kayıtlı e-postaya sıfırlama linki gönderir', async () => {
      const { servis, emailGonderici } = servisiOlustur({
        kullaniciRepo: { emailIleBul: jest.fn().mockResolvedValue(sahteKullanici()) },
      });

      await servis.sifremiUnuttum({ email: 'elif@example.com' });

      expect(emailGonderici.gonder).toHaveBeenCalledWith(
        'elif@example.com',
        expect.any(String),
        expect.stringContaining('reset-token'),
      );
    });
  });
});
