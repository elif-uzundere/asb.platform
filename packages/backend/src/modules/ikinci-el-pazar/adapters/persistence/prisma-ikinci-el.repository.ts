import {
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import {
  IkinciElIlaniDurumu,
  Prisma,
} from '@prisma/client';

import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import {
  IkinciElIlani,
  IkinciElIlaniOlusturmaVerisi,
  IkinciElRepository,
} from '../../domain';

@Injectable()
export class PrismaIkinciElRepository
  extends IkinciElRepository {
  constructor(
    private readonly prismaService: PrismaService,
  ) {
    super();
  }

  async aktifIlanlariGetir(): Promise<IkinciElIlani[]> {
    const ilanlar =
        await this.prismaService.ikinciElIlani.findMany({
      where: {
        durum: IkinciElIlaniDurumu.aktif,
      },
      include: {
        kullanici: {
          select: {
            id: true,
            ad: true,
            soyad: true,
            firma: {
              select: {
                ad: true,
              },
            },
          },
        },
      },
      orderBy: {
        olusturmaTarihi: 'desc',
      },
    });

    return ilanlar.map((ilan) => ({
      id: ilan.id,
      kullaniciId: ilan.kullaniciId,
      baslik: ilan.baslik,
      aciklama: ilan.aciklama,
      fiyat: Number(ilan.fiyat),
      kategori: ilan.kategori,
      urunDurumu: ilan.urunDurumu,
      fotografUrls: ilan.fotografUrls,
      durum: ilan.durum,
      firmaAdi:
          ilan.kullanici.firma?.ad ??
          '${ilan.kullanici.ad} ${ilan.kullanici.soyad}',
      olusturmaTarihi: ilan.olusturmaTarihi,
    }));
  }

  async ilanOlustur(
    veri: IkinciElIlaniOlusturmaVerisi,
  ): Promise<IkinciElIlani> {
    const kullanici =
        await this.prismaService.kullanici.findUnique({
      where: {
        id: veri.kullaniciId,
      },
      select: {
        id: true,
        ad: true,
        soyad: true,
        firma: {
          select: {
            ad: true,
          },
        },
      },
    });

    if (!kullanici) {
      throw new NotFoundException(
        'İlanı oluşturan kullanıcı bulunamadı',
      );
    }

    const ilan =
        await this.prismaService.ikinciElIlani.create({
      data: {
        kullaniciId: veri.kullaniciId,
        baslik: veri.baslik,
        aciklama: veri.aciklama,
        fiyat: new Prisma.Decimal(veri.fiyat),
        kategori: veri.kategori,
        urunDurumu: veri.urunDurumu,
        fotografUrls: veri.fotografUrls,
        durum: IkinciElIlaniDurumu.aktif,
      },
    });

    return {
      id: ilan.id,
      kullaniciId: ilan.kullaniciId,
      baslik: ilan.baslik,
      aciklama: ilan.aciklama,
      fiyat: Number(ilan.fiyat),
      kategori: ilan.kategori,
      urunDurumu: ilan.urunDurumu,
      fotografUrls: ilan.fotografUrls,
      durum: ilan.durum,
      firmaAdi:
          kullanici.firma?.ad ??
          '${kullanici.ad} ${kullanici.soyad}',
      olusturmaTarihi: ilan.olusturmaTarihi,
    };
  }
}