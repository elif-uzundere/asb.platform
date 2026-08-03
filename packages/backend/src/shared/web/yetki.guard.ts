import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Reflector } from '@nestjs/core';

import { PrismaService } from '../infrastructure/prisma.service';
import { YETKI_METADATA_ANAHTARI } from './yetki.decorator';
import type { YetkiKodu } from '@asb/shared-types';

interface JwtPayload {
  sub: string;
  email: string;
  rol: string;
}

@Injectable()
export class YetkiGuard implements CanActivate {
  constructor(
    private readonly reflector: Reflector,
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const gerekliYetkiler = this.reflector.getAllAndOverride<YetkiKodu[]>(YETKI_METADATA_ANAHTARI, [
      context.getHandler(),
      context.getClass(),
    ]);

    if (!gerekliYetkiler || gerekliYetkiler.length === 0) {
      return true;
    }

    const istek = context.switchToHttp().getRequest();
    const authorization = istek.headers.authorization;

    if (!authorization || !authorization.startsWith('Bearer ')) {
      throw new UnauthorizedException('Giriş yapmanız gerekiyor.');
    }

    const token = authorization.replace('Bearer ', '');

    let payload: JwtPayload;
    try {
      payload = await this.jwtService.verifyAsync<JwtPayload>(token);
    } catch {
      throw new UnauthorizedException('Geçersiz veya süresi dolmuş token.');
    }

    const eslesme = await this.prisma.rolYetki.findFirst({
      where: {
        rol: payload.rol as never,
        yetki: { in: gerekliYetkiler as never[] },
      },
    });

    if (!eslesme) {
      throw new ForbiddenException('Bu işlem için yetkiniz bulunmuyor.');
    }

    istek.user = payload;

    return true;
  }
}
