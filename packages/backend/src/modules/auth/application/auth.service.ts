import { randomUUID } from 'crypto';
import type {
  RegisterRequest,
  LoginRequest,
  LoginResponse,
  KullaniciOzet,
  SifremiUnuttumRequest,
  SifreSifirlaRequest,
} from '@asb/shared-types';
import {
  Email,
  Kullanici,
  KullaniciRepository,
  SifreHashPort,
  TokenUreticiPort,
  EmailGonderPort,
  EmailZatenKayitliException,
  GecersizKimlikBilgisiException,
  GecersizSifirlamaTokenException,
} from '../domain';

export class AuthService {
  constructor(
    private readonly kullaniciRepo: KullaniciRepository,
    private readonly sifreHash: SifreHashPort,
    private readonly tokenUretici: TokenUreticiPort,
    private readonly emailGonderici: EmailGonderPort,
    private readonly sifirlamaLinkTabani: string,
  ) {}

  async kayitOl(dto: RegisterRequest): Promise<LoginResponse> {
    const email = new Email(dto.email);

    const mevcut = await this.kullaniciRepo.emailIleBul(email.toString());
    if (mevcut) {
      throw new EmailZatenKayitliException(email.toString());
    }

    const hash = await this.sifreHash.hashle(dto.sifre);

    const yeniKullanici = new Kullanici(
      randomUUID(),
      email,
      hash,
      dto.ad,
      dto.soyad,
      'ziyaretci',
      null,
      false,
    );

    const kaydedilen = await this.kullaniciRepo.kaydet(yeniKullanici);
    return this.yanitOlustur(kaydedilen);
  }

  async girisYap(dto: LoginRequest): Promise<LoginResponse> {
    const email = new Email(dto.email);

    const kullanici = await this.kullaniciRepo.emailIleBul(email.toString());
    if (!kullanici) {
      throw new GecersizKimlikBilgisiException();
    }

    const dogru = await this.sifreHash.dogrula(dto.sifre, kullanici.sifreHash);
    if (!dogru) {
      throw new GecersizKimlikBilgisiException();
    }

    return this.yanitOlustur(kullanici, dto.beniHatirla);
  }

  async sifremiUnuttum(dto: SifremiUnuttumRequest): Promise<void> {
    const kullanici = await this.kullaniciRepo.emailIleBul(dto.email);
    if (!kullanici) return;

    const token = await this.tokenUretici.sifirlamaTokenUret(kullanici);
    const link = `${this.sifirlamaLinkTabani}?token=${token}`;
    const icerik = `<p>Merhaba ${kullanici.ad},</p><p>Şifreni sıfırlamak için <a href="${link}">buraya tıkla</a>. Bu link 15 dakika geçerlidir.</p>`;
    await this.emailGonderici.gonder(
      kullanici.email.toString(),
      'ASB Platform - Şifre Sıfırlama',
      icerik,
    );
  }

  async sifreSifirla(dto: SifreSifirlaRequest): Promise<void> {
    const kullaniciId = await this.tokenUretici.sifirlamaTokenDogrula(dto.token);
    if (!kullaniciId) {
      throw new GecersizSifirlamaTokenException();
    }
    const yeniHash = await this.sifreHash.hashle(dto.yeniSifre);
    await this.kullaniciRepo.sifreGuncelle(kullaniciId, yeniHash);
  }

  private async yanitOlustur(kullanici: Kullanici, uzunSureli = false): Promise<LoginResponse> {
    const accessToken = await this.tokenUretici.uret(kullanici, uzunSureli);
    const ozet: KullaniciOzet = {
      id: kullanici.id,
      ad: kullanici.ad,
      soyad: kullanici.soyad,
      email: kullanici.email.toString(),
      rol: kullanici.rol,
      firmaId: kullanici.firmaId,
      epostaDogrulandi: kullanici.epostaDogrulandi,
    };
    return { accessToken, kullanici: ozet };
  }
}