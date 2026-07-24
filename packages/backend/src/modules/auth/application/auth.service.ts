import { randomUUID } from 'crypto';
import type { RegisterRequest, LoginRequest, LoginResponse, KullaniciOzet } from '@asb/shared-types';
import {
  Email,
  Kullanici,
  KullaniciRepository,
  SifreHashPort,
  TokenUreticiPort,
  EmailZatenKayitliException,
  GecersizKimlikBilgisiException,
} from '../domain';

export class AuthService {
  constructor(
    private readonly kullaniciRepo: KullaniciRepository,
    private readonly sifreHash: SifreHashPort,
    private readonly tokenUretici: TokenUreticiPort,
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

    return this.yanitOlustur(kullanici);
  }

  private async yanitOlustur(kullanici: Kullanici): Promise<LoginResponse> {
    const accessToken = await this.tokenUretici.uret(kullanici);
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