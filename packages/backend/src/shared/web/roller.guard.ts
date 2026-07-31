// "Bu kullanıcı bu işlemi yapabilir mi?" sorusunu cevaplayan guard.
//
// JwtAuthGuard'dan SONRA çalışmak zorunda: kullanıcıyı request'e o koyuyor.
// Sıra `@UseGuards(JwtAuthGuard, RollerGuard)` yazımındaki sıradan gelir.
//
// Bu guard tek başına kullanılmaz; @Roller() etiketi olmayan endpoint'lerde
// hiçbir şey yapmadan geçer.

import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type { KullaniciRolu } from '@asb/shared-types';
import { KullaniciliRequest } from './jwt-auth.guard';
import { ROLLER_ANAHTARI } from './roller.decorator';

@Injectable()
export class RollerGuard implements CanActivate {
  // Reflector, decorator'ların yapıştırdığı metadata'yı okumaya yarayan
  // Nest'in kendi aracı.
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    // Önce metodun üstüne, yoksa class'ın üstüne bakar (metot class'ı ezer).
    const izinliRoller = this.reflector.getAllAndOverride<
      KullaniciRolu[] | undefined
    >(ROLLER_ANAHTARI, [context.getHandler(), context.getClass()]);

    // @Roller() yazılmamış → bu endpoint'te rol kısıtı yok, karışma.
    if (!izinliRoller || izinliRoller.length === 0) {
      return true;
    }

    const kullanici = context
      .switchToHttp()
      .getRequest<KullaniciliRequest>().kullanici;

    // Kullanıcı yoksa JwtAuthGuard eklenmeyi unutulmuş demektir — yapılandırma
    // hatası. Sessizce geçirmek yerine isteği reddediyoruz (fail-safe).
    if (!kullanici || !izinliRoller.includes(kullanici.rol)) {
      throw new ForbiddenException('Bu işlem için yetkiniz yok');
    }

    return true;
  }
}
