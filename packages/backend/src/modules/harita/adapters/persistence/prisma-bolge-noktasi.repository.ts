import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import { BolgeNoktasiRepository } from '../../domain';

@Injectable()
export class PrismaBolgeNoktasiRepository implements BolgeNoktasiRepository {
  constructor(private readonly prisma: PrismaService) {}

  async adiGetir(id: string): Promise<string | null> {
    const kayit = await this.prisma.bolgeNoktasi.findUnique({ where: { id }, select: { ad: true } });
    return kayit?.ad ?? null;
  }
}
