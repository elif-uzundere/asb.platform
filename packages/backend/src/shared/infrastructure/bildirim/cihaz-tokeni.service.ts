import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma.service';

/**
 * Diğer modüllerin desenindeki gibi ayrı bir port/adapter'a bölünmedi —
 * bu, gerçek bir iş kuralı taşımayan, saf bir CRUD yardımcı sınıfı
 * (`PrismaService`'in kendisi gibi doğrudan enjekte edilebilir altyapı).
 */
@Injectable()
export class CihazTokeniService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * `token` unique olduğu için upsert — aynı cihaz token'ı yenilendiğinde
   * (ya da kullanıcı değiştiğinde, örn. paylaşımlı bir cihaz) çoğaltılmaz,
   * sahibi güncellenir.
   */
  async kaydet(kullaniciId: string, token: string, platform: 'android' | 'ios' | 'web'): Promise<void> {
    await this.prisma.cihazTokeni.upsert({
      where: { token },
      update: { kullaniciId, platform },
      create: { kullaniciId, token, platform },
    });
  }
}
