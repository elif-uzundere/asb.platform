// RollerGuard'ın davranış sözleşmesi.
//
// Özellikle son test önemli: JwtAuthGuard eklenmeyi unutulduğunda guard
// SESSİZCE GEÇİRMEZ, reddeder. Güvenlik kodunda varsayılan davranış "hayır"
// olmalı (fail-safe) — yapılandırma hatası açık kapı bırakmasın.

import { ExecutionContext, ForbiddenException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type { KullaniciRolu } from '@asb/shared-types';
import { KullaniciliRequest } from './jwt-auth.guard';
import { RollerGuard } from './roller.guard';

function sahteContext(rol?: KullaniciRolu): ExecutionContext {
  const request = {
    kullanici: rol ? { id: 'k1', email: 'a@b.com', rol } : undefined,
  } as KullaniciliRequest;

  return {
    switchToHttp: () => ({ getRequest: () => request }),
    getHandler: () => undefined,
    getClass: () => undefined,
  } as unknown as ExecutionContext;
}

function sahteReflector(izinliRoller?: KullaniciRolu[]): Reflector {
  return {
    getAllAndOverride: jest.fn().mockReturnValue(izinliRoller),
  } as unknown as Reflector;
}

describe('RollerGuard', () => {
  it('@Roller() yazılmamış endpointe karışmaz', () => {
    const guard = new RollerGuard(sahteReflector(undefined));

    expect(guard.canActivate(sahteContext('ziyaretci'))).toBe(true);
  });

  it('boş @Roller() listesini kısıt saymaz', () => {
    const guard = new RollerGuard(sahteReflector([]));

    expect(guard.canActivate(sahteContext('ziyaretci'))).toBe(true);
  });

  it('rol eşleşiyorsa geçirir', () => {
    const guard = new RollerGuard(sahteReflector(['admin']));

    expect(guard.canActivate(sahteContext('admin'))).toBe(true);
  });

  it('birden fazla izinli rolden birini taşımak yeterlidir', () => {
    const guard = new RollerGuard(
      sahteReflector(['admin', 'firma_yetkilisi']),
    );

    expect(guard.canActivate(sahteContext('firma_yetkilisi'))).toBe(true);
  });

  it('rol yetersizse reddeder', () => {
    const guard = new RollerGuard(sahteReflector(['admin']));

    expect(() => guard.canActivate(sahteContext('ziyaretci'))).toThrow(
      ForbiddenException,
    );
  });

  it('JwtAuthGuard eklenmemişse (kullanıcı yok) reddeder — fail-safe', () => {
    const guard = new RollerGuard(sahteReflector(['admin']));

    expect(() => guard.canActivate(sahteContext(undefined))).toThrow(
      ForbiddenException,
    );
  });
});
