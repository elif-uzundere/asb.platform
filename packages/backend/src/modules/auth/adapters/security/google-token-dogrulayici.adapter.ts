// GoogleTokenDogrulayiciPort'un gerçek uygulaması — Google'ın kendi
// kütüphanesi (google-auth-library) burada, sadece bu dosyada kullanılır.
// application katmanı bu kütüphaneyi hiç bilmez (bkz. domain/
// google-token-dogrulayici.port.ts).

import { Injectable } from '@nestjs/common';
import { OAuth2Client } from 'google-auth-library';
import { GecersizGoogleTokenException } from '../../domain';
import type { GoogleKullaniciBilgisi, GoogleTokenDogrulayiciPort } from '../../domain';

@Injectable()
export class GoogleTokenDogrulayiciAdapter implements GoogleTokenDogrulayiciPort {
  private readonly client = new OAuth2Client();

  // Flutter uygulaması Web VE Android'den giriş yapabiliyor — ikisinin de
  // OAuth istemci kimliği burada "geçerli alıcı" (audience) olarak kabul
  // edilmeli, yoksa bir platformdan üretilen token diğerinde reddedilir.
  private readonly gecerliAudiencelar = [
    process.env.GOOGLE_CLIENT_ID_WEB,
    process.env.GOOGLE_CLIENT_ID_ANDROID,
  ].filter((deger): deger is string => Boolean(deger));

  async dogrula(idToken: string): Promise<GoogleKullaniciBilgisi> {
    try {
      const ticket = await this.client.verifyIdToken({
        idToken,
        audience: this.gecerliAudiencelar,
      });
      const payload = ticket.getPayload();
      if (!payload?.email) {
        throw new GecersizGoogleTokenException();
      }

      return {
        email: payload.email,
        ad: payload.given_name ?? payload.name ?? 'Kullanıcı',
        soyad: payload.family_name ?? '-',
      };
    } catch {
      throw new GecersizGoogleTokenException();
    }
  }
}
