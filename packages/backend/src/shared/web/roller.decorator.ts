// Bir endpoint'i belirli rollerle sınırlamak için kullanılan işaret.
//
// Burada HİÇBİR kontrol yapılmıyor — bu decorator sadece metoda bir etiket
// (metadata) yapıştırıyor: "bu endpoint şu rolleri istiyor". Etiketi okuyup
// karar veren taraf RollerGuard.
//
// Neden ikiye ayrılmış? Çünkü "ne isteniyor" (bildirim) ile "nasıl kontrol
// edilir" (mantık) iki ayrı sorumluluk. Controller'da sadece niyeti görürsün,
// kontrolün nasıl yapıldığı gözünü yormaz.

import { SetMetadata } from '@nestjs/common';
import type { KullaniciRolu } from '@asb/shared-types';

/** RollerGuard'ın metadata'yı bulmak için kullandığı anahtar. */
export const ROLLER_ANAHTARI = 'roller';

/**
 * Kullanımı:
 * ```ts
 * @Post()
 * @UseGuards(JwtAuthGuard, RollerGuard)
 * @Roller('admin')
 * async firmaOlustur() { ... }
 * ```
 * Birden fazla rol verilebilir: `@Roller('admin', 'firma_yetkilisi')`
 */
export const Roller = (...roller: KullaniciRolu[]) =>
  SetMetadata(ROLLER_ANAHTARI, roller);
