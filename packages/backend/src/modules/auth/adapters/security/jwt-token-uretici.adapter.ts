import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Kullanici, TokenUreticiPort } from '../../domain';

@Injectable()
export class JwtTokenUreticiAdapter implements TokenUreticiPort {
  constructor(private readonly jwtService: JwtService) {}

  async uret(kullanici: Kullanici): Promise<string> {
    const payload = {
      sub: kullanici.id,
      email: kullanici.email.toString(),
      rol: kullanici.rol,
    };
    return this.jwtService.signAsync(payload);
  }
}