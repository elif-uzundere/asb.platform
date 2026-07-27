import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Kullanici, TokenUreticiPort } from '../../domain';

const KISA_SURE = '1d';
const UZUN_SURE = '30d';
const SIFIRLAMA_SURESI = '15m';
const SIFIRLAMA_AMACI = 'sifre-sifirlama';

@Injectable()
export class JwtTokenUreticiAdapter implements TokenUreticiPort {
  constructor(private readonly jwtService: JwtService) {}

  async uret(kullanici: Kullanici, uzunSureli = false): Promise<string> {
    const payload = {
      sub: kullanici.id,
      email: kullanici.email.toString(),
      rol: kullanici.rol,
    };
    return this.jwtService.signAsync(payload, {
      expiresIn: uzunSureli ? UZUN_SURE : KISA_SURE,
    });
  }

  async sifirlamaTokenUret(kullanici: Kullanici): Promise<string> {
    return this.jwtService.signAsync(
      { sub: kullanici.id, amac: SIFIRLAMA_AMACI },
      { expiresIn: SIFIRLAMA_SURESI },
    );
  }

  async sifirlamaTokenDogrula(token: string): Promise<string | null> {
    try {
      const payload = await this.jwtService.verifyAsync<{ sub: string; amac: string }>(token);
      if (payload.amac !== SIFIRLAMA_AMACI) return null;
      return payload.sub;
    } catch {
      return null;
    }
  }
}