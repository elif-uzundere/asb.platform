// "Bu isteği gönderen kim?" sorusunu cevaplayan guard.
//
// Guard nedir: Nest'te istek controller'a ULAŞMADAN ÖNCE çalışan bir kapı
// bekçisi. `true` dönerse istek devam eder, exception fırlatırsa istek orada
// biter ve controller'daki kod hiç çalışmaz.
//
// Bu guard sadece KİMLİK doğrular (token geçerli mi, kim bu kullanıcı?).
// YETKİ kontrolü (bu kişi bunu yapabilir mi?) ayrı bir guard'ın işi —
// bkz. roller.guard.ts. İkisini ayırmak Single Responsibility gereği:
// "giriş yapmış mı" ile "admin mi" birbirinden bağımsız sorular.

import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';
import { AktifKullanici, JwtIcerigi } from './jwt-icerigi';

/**
 * Guard doğrulamayı geçince kullanıcıyı request nesnesine iliştirir.
 * Express'in `Request` tipinde böyle bir alan olmadığı için genişletiyoruz.
 */
export interface KullaniciliRequest extends Request {
  kullanici?: AktifKullanici;
}

@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private readonly jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<KullaniciliRequest>();
    const token = this.tokeniAyikla(request);

    // Mesajlar Türkçe: GlobalExceptionFilter bunları ApiResponseDto zarfına
    // sarıyor ve Flutter `error.message`'ı kullanıcıya olduğu gibi gösteriyor.
    if (!token) {
      throw new UnauthorizedException('Bu işlem için giriş yapmalısınız');
    }

    try {
      const icerik = await this.jwtService.verifyAsync<JwtIcerigi>(token);

      // Bundan sonra controller'lar `@AktifKullaniciBilgisi()` ile buna erişir.
      request.kullanici = {
        id: icerik.sub,
        email: icerik.email,
        rol: icerik.rol,
      };
      return true;
    } catch {
      // İmza geçersiz, süresi dolmuş ya da payload bozuk — hepsi aynı cevap.
      // Hangisi olduğunu söylemiyoruz: saldırgana bilgi vermemek için.
      throw new UnauthorizedException('Oturumunuz geçersiz veya süresi dolmuş');
    }
  }

  /** `Authorization: Bearer <token>` başlığından token'ı çıkarır. */
  private tokeniAyikla(request: KullaniciliRequest): string | null {
    const baslik = request.headers.authorization;
    if (!baslik) return null;

    const [tur, token] = baslik.split(' ');
    return tur === 'Bearer' && token ? token : null;
  }
}
