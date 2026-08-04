import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import {
  IsOrtagiData,
  IsOrtagiRepository,
} from '../../domain';

@Injectable()
export class PrismaIsOrtagiRepository extends IsOrtagiRepository {
  constructor(
    private readonly prisma: PrismaService,
  ) {
    super();
  }

  async tumunuGetir(): Promise<IsOrtagiData[]> {
    return this.prisma.isOrtagi.findMany({
      orderBy: {
        ad: 'asc',
      },
      select: {
        id: true,
        ad: true,
        logoUrl: true,
        kategori: true,
      },
    });
  }
}