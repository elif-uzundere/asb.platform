import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../../shared/infrastructure/prisma.service';
import { Email, Kullanici, KullaniciRepository, KullaniciRolu } from '../../domain';

@Injectable()
export class PrismaKullaniciRepository implements KullaniciRepository {
  constructor(private readonly prisma: PrismaService) {}

  async emailIleBul(email: string): Promise<Kullanici | null> {
    const kayit = await this.prisma.kullanici.findUnique({ where: { email } });
    if (!kayit) return null;
    return this.entiteyeCevir(kayit);
  }

  async kaydet(kullanici: Kullanici): Promise<Kullanici> {
    const kayit = await this.prisma.kullanici.create({
      data: {
        id: kullanici.id,
        email: kullanici.email.toString(),
        sifreHash: kullanici.sifreHash,
        ad: kullanici.ad,
        soyad: kullanici.soyad,
        rol: kullanici.rol,
        firmaId: kullanici.firmaId,
        epostaDogrulandi: kullanici.epostaDogrulandi,
      },
    });
    return this.entiteyeCevir(kayit);
  }

  async idIleBul(id: string): Promise<Kullanici | null> {
    const kayit = await this.prisma.kullanici.findUnique({ where: { id } });
    if (!kayit) return null;
    return this.entiteyeCevir(kayit);
  }

  async sifreGuncelle(id: string, yeniSifreHash: string): Promise<void> {
    await this.prisma.kullanici.update({
      where: { id },
      data: { sifreHash: yeniSifreHash },
    });
  }

  private entiteyeCevir(kayit: {
    id: string;
    email: string;
    sifreHash: string | null;
    ad: string;
    soyad: string;
    rol: string;
    firmaId: string | null;
    epostaDogrulandi: boolean;
  }): Kullanici {
    return new Kullanici(
      kayit.id,
      new Email(kayit.email),
      kayit.sifreHash ?? '',
      kayit.ad,
      kayit.soyad,
      kayit.rol as KullaniciRolu,
      kayit.firmaId,
      kayit.epostaDogrulandi,
    );
  }
}