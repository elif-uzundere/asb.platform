// Controller metodunda oturum açmış kullanıcıyı almanın temiz yolu.
//
// Bu olmasaydı her controller'da şunu yazmak gerekirdi:
//   @Req() request: KullaniciliRequest  →  request.kullanici!.id
// Yani her controller Express'in request nesnesini ve guard'ın onu nasıl
// doldurduğunu bilmek zorunda kalırdı. Param decorator bu detayı saklıyor:
// controller sadece "bana aktif kullanıcıyı ver" diyor.

import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { KullaniciliRequest } from './jwt-auth.guard';
import { AktifKullanici } from './jwt-icerigi';

/**
 * Kullanımı:
 * ```ts
 * @Post()
 * @UseGuards(JwtAuthGuard)
 * async olustur(@AktifKullaniciBilgisi() kullanici: AktifKullanici) {
 *   // kullanici.id, kullanici.rol ...
 * }
 * ```
 *
 * `undefined` dönebilir — JwtAuthGuard eklenmemiş bir endpoint'te kullanılırsa.
 */
export const AktifKullaniciBilgisi = createParamDecorator(
  (_veri: unknown, context: ExecutionContext): AktifKullanici | undefined =>
    context.switchToHttp().getRequest<KullaniciliRequest>().kullanici,
);
