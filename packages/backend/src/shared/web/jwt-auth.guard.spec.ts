// JwtAuthGuard'ın davranış sözleşmesi.
//
// Guard saf mantık olduğu için Nest'i ayağa kaldırmaya gerek yok: bağımlılığını
// (JwtService) elle veriyoruz, ExecutionContext'i taklit ediyoruz. Mimari
// kuralın "framework'süz test edilebilirlik" vaadi pratikte bu demek.

import { UnauthorizedException } from '@nestjs/common';
import { ExecutionContext } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { JwtAuthGuard, KullaniciliRequest } from './jwt-auth.guard';

function sahteContext(
  baslik?: string,
): { context: ExecutionContext; request: KullaniciliRequest } {
  const request = {
    headers: baslik ? { authorization: baslik } : {},
  } as KullaniciliRequest;

  const context = {
    switchToHttp: () => ({ getRequest: () => request }),
  } as unknown as ExecutionContext;

  return { context, request };
}

describe('JwtAuthGuard', () => {
  it('Authorization başlığı yoksa isteği reddeder', async () => {
    const guard = new JwtAuthGuard({} as JwtService);
    const { context } = sahteContext();

    await expect(guard.canActivate(context)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });

  it('başlık Bearer değilse reddeder', async () => {
    const guard = new JwtAuthGuard({} as JwtService);
    const { context } = sahteContext('Basic a1b2c3');

    await expect(guard.canActivate(context)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });

  it('token geçersiz/süresi dolmuşsa reddeder', async () => {
    const jwtService = {
      verifyAsync: jest.fn().mockRejectedValue(new Error('jwt expired')),
    } as unknown as JwtService;
    const guard = new JwtAuthGuard(jwtService);
    const { context } = sahteContext('Bearer bozuk.token.xyz');

    await expect(guard.canActivate(context)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
  });

  it('geçerli tokende kullanıcıyı request e ekler ve geçirir', async () => {
    const jwtService = {
      verifyAsync: jest.fn().mockResolvedValue({
        sub: 'k1',
        email: 'elif@example.com',
        rol: 'admin',
        firmaId: null,
        cookzoneIsletmeId: null,
      }),
    } as unknown as JwtService;
    const guard = new JwtAuthGuard(jwtService);
    const { context, request } = sahteContext('Bearer gecerli.token');

    await expect(guard.canActivate(context)).resolves.toBe(true);

    // Controller'lar @AktifKullaniciBilgisi() ile tam olarak bunu okuyacak.
    expect(request.kullanici).toEqual({
      id: 'k1',
      email: 'elif@example.com',
      rol: 'admin',
      firmaId: null,
      cookzoneIsletmeId: null,
    });
  });

  it('hata mesajı hangi sebeple başarısız olduğunu sızdırmaz', async () => {
    const jwtService = {
      verifyAsync: jest.fn().mockRejectedValue(new Error('invalid signature')),
    } as unknown as JwtService;
    const guard = new JwtAuthGuard(jwtService);
    const { context } = sahteContext('Bearer sahte.imza');

    await expect(guard.canActivate(context)).rejects.toThrow(
      'Oturumunuz geçersiz veya süresi dolmuş',
    );
  });
});
