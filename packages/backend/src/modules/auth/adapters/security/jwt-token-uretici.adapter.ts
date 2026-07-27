import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Kullanici, TokenUreticiPort } from '../../domain';

const KISA_SURE = '1d';
const UZUN_SURE = '30d';

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
}