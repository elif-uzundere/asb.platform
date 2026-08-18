import { randomUUID } from 'crypto';
import { Injectable } from '@nestjs/common';

import { PrismaService } from '../../../../shared/infrastructure/prisma.service';

import {
  AcilDurumBildirimDurumu,
  AcilDurumBildirimi,
  AcilDurumBildirimiOlusturVerisi,
  AcilDurumBilgisi,
  AcilDurumRepository,
  AcilDurumTuru,
  ToplanmaAlani,
} from '../../domain';

@Injectable()
export class PrismaAcilDurumRepository extends AcilDurumRepository {
  constructor(
    private readonly prismaService: PrismaService,
  ) {
    super();
  }

  async bilgileriGetir(): Promise<AcilDurumBilgisi[]> {
    const bilgiler =
        await this.prismaService.acilDurumBilgisi.findMany();

    return bilgiler.map((bilgi) => ({
      id: bilgi.id,
      tur: bilgi.tur,
      telefon: bilgi.telefon,
      telefon2: bilgi.telefon2,
      eposta: bilgi.eposta,
      adres: bilgi.adres,
      aciklama: bilgi.aciklama,
      calismaSaatleri: bilgi.calismaSaatleri,
    }));
  }

  async toplanmaAlanlariniGetir(): Promise<ToplanmaAlani[]> {
    const alanlar =
        await this.prismaService.toplanmaAlani.findMany({
      where: {
        aktif: true,
      },
      orderBy: {
        sira: 'asc',
      },
    });

    return alanlar.map((alan) => ({
      id: alan.id,
      ad: alan.ad,
      aciklama: alan.aciklama,
      enlem: Number(alan.enlem),
      boylam: Number(alan.boylam),
      sira: alan.sira,
    }));
  }

  async bildirimOlustur(veri: AcilDurumBildirimiOlusturVerisi): Promise<AcilDurumBildirimi> {
    const bildirim = await this.prismaService.acilDurumBildirimi.create({
      data: {
        id: randomUUID(),
        kullaniciId: veri.kullaniciId,
        tur: veri.tur,
        aciklama: veri.aciklama,
      },
    });
    return this.bildirimeCevir(bildirim);
  }

  async bildirimlerimGetir(kullaniciId: string): Promise<AcilDurumBildirimi[]> {
    const bildirimler = await this.prismaService.acilDurumBildirimi.findMany({
      where: { kullaniciId },
      orderBy: { olusturmaTarihi: 'desc' },
    });
    return bildirimler.map((bildirim) => this.bildirimeCevir(bildirim));
  }

  async turIleListele(tur: AcilDurumTuru): Promise<AcilDurumBildirimi[]> {
    const bildirimler = await this.prismaService.acilDurumBildirimi.findMany({
      where: { tur },
      orderBy: { olusturmaTarihi: 'desc' },
    });
    return bildirimler.map((bildirim) => this.bildirimeCevir(bildirim));
  }

  async bildirimIdIleBul(id: string): Promise<AcilDurumBildirimi | null> {
    const bildirim = await this.prismaService.acilDurumBildirimi.findUnique({ where: { id } });
    return bildirim ? this.bildirimeCevir(bildirim) : null;
  }

  async bildirimDurumGuncelle(id: string, durum: AcilDurumBildirimDurumu): Promise<AcilDurumBildirimi> {
    const bildirim = await this.prismaService.acilDurumBildirimi.update({
      where: { id },
      data: { durum },
    });
    return this.bildirimeCevir(bildirim);
  }

  private bildirimeCevir(bildirim: {
    id: string;
    kullaniciId: string;
    tur: string;
    aciklama: string | null;
    durum: string;
    olusturmaTarihi: Date;
  }): AcilDurumBildirimi {
    return {
      id: bildirim.id,
      kullaniciId: bildirim.kullaniciId,
      tur: bildirim.tur as AcilDurumBildirimi['tur'],
      aciklama: bildirim.aciklama,
      durum: bildirim.durum as AcilDurumBildirimi['durum'],
      olusturmaTarihi: bildirim.olusturmaTarihi,
    };
  }
}