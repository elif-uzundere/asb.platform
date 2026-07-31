import { Injectable } from '@nestjs/common';
// Prisma'nın ÜRETTİĞİ tip. Daha önce burada elle yazılmış bir `FirmaKaydi`
// tipi vardı; şemaya kolon eklenince o tip sessizce ayrışırdı. Artık şema
// değişirse derleyici burayı da uyarıyor.
// Domain sınıfımızın adı da `Firma` olduğu için takma adla alıyoruz.
import type { Firma as FirmaKaydi } from '@prisma/client';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import { Firma, FirmaRepository } from '../../domain';
import { FirmaListeRequest } from '@asb/shared-types';

/**
 * Herkese açık listenin görünürlük süzgeci (BR-1 + `aktif`).
 * SQL'e gömülü: onaylanmamış kayıtlar veritabanından hiç çıkmıyor.
 */
const GORUNUR_KOSULU = { onayDurumu: 'onaylandi', aktif: true } as const;

@Injectable()
export class PrismaFirmaRepository implements FirmaRepository {
  constructor(private readonly prisma: PrismaService) {}

  async listele(filtre: FirmaListeRequest): Promise<Firma[]> {
    const kayitlar = await this.prisma.firma.findMany({
      where: {
        ...GORUNUR_KOSULU,
        ad: filtre.arama ? { contains: filtre.arama, mode: 'insensitive' } : undefined,
        sektor: filtre.sektor ? { equals: filtre.sektor, mode: 'insensitive' } : undefined,
      },
      orderBy: { ad: 'asc' },
    });
    return kayitlar.map((kayit) => this.entiteyeCevir(kayit));
  }

  async idIleBul(id: string): Promise<Firma | null> {
    // Süzgeç YOK — admin onay için onaylanmamış firmayı da okumak zorunda.
    const kayit = await this.prisma.firma.findUnique({ where: { id } });
    return kayit ? this.entiteyeCevir(kayit) : null;
  }

  async sektorleriGetir(): Promise<string[]> {
    // `distinct` + sadece `sektor` kolonu: tüm satırları çekmeye gerek yok.
    // Görünür kosulu burada da uygulanıyor — yoksa tıklandığında boş sonuç
    // veren bir sektör çipi oluşurdu.
    const kayitlar = await this.prisma.firma.findMany({
      where: GORUNUR_KOSULU,
      distinct: ['sektor'],
      select: { sektor: true },
      orderBy: { sektor: 'asc' },
    });
    return kayitlar.map((kayit) => kayit.sektor);
  }

  async onayBekleyenleriGetir(): Promise<Firma[]> {
    const kayitlar = await this.prisma.firma.findMany({
      where: { onayDurumu: { not: 'onaylandi' } },
      orderBy: { olusturmaTarihi: 'asc' }, // en eski başvuru önce
    });
    return kayitlar.map((kayit) => this.entiteyeCevir(kayit));
  }

  async olustur(firma: Firma): Promise<Firma> {
    const kayit = await this.prisma.firma.create({
      data: {
        id: firma.id,
        ad: firma.ad,
        logoUrl: firma.logoUrl,
        sektor: firma.sektor,
        adres: firma.adres,
        telefon: firma.telefon,
        eposta: firma.eposta,
        onayDurumu: firma.onayDurumu,
        aktif: firma.aktif,
        webAdres: firma.webAdres,
        kurulusTarihi: firma.kurulusTarihi,
        personelSayisi: firma.personelSayisi,
      },
    });
    return this.entiteyeCevir(kayit);
  }

  async onayDurumuGuncelle(id: string, durum: Firma['onayDurumu']): Promise<Firma> {
    const kayit = await this.prisma.firma.update({
      where: { id },
      data: { onayDurumu: durum },
    });
    return this.entiteyeCevir(kayit);
  }

  /** Veritabanı satırını domain nesnesine çevirir (tek dönüşüm noktası). */
  private entiteyeCevir(kayit: FirmaKaydi): Firma {
    return new Firma(
      kayit.id,
      kayit.ad,
      kayit.logoUrl,
      kayit.sektor,
      kayit.adres,
      kayit.telefon,
      kayit.eposta,
      kayit.onayDurumu,
      kayit.aktif,
      kayit.webAdres,
      kayit.kurulusTarihi,
      kayit.personelSayisi,
      kayit.guncellemeTarihi,
    );
  }
}
