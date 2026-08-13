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
        telefon: kullanici.telefon,
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

  async epostaGuncelle(id: string, yeniEposta: string): Promise<void> {
    await this.prisma.kullanici.update({
      where: { id },
      // Yeni e-posta henüz doğrulanmadı — gerçek bir doğrulama akışı
      // (link/kod gönderme) bu fazda YOK, bkz. YENI-MODUL-REHBERI.md'deki
      // "henüz kesinleşmemiş" not deseni. Alan yine de yanlış bilgi
      // vermesin diye false'a çekiliyor.
      data: { email: yeniEposta, epostaDogrulandi: false },
    });
  }

  async profilGuncelle(
    id: string,
    veri: { ad: string; soyad: string; telefon: string | null },
  ): Promise<Kullanici> {
    const kayit = await this.prisma.kullanici.update({
      where: { id },
      data: { ad: veri.ad, soyad: veri.soyad, telefon: veri.telefon },
    });
    return this.entiteyeCevir(kayit);
  }

  private entiteyeCevir(kayit: {
    id: string;
    email: string;
    telefon: string | null;
    sifreHash: string | null;
    ad: string;
    soyad: string;
    rol: string;
    firmaId: string | null;
    epostaDogrulandi: boolean;
    cookzoneIsletmeId?: string | null;
  }): Kullanici {
    return new Kullanici(
      kayit.id,
      new Email(kayit.email),
      kayit.sifreHash,
      kayit.ad,
      kayit.soyad,
      kayit.rol as KullaniciRolu,
      kayit.firmaId,
      kayit.epostaDogrulandi,
      kayit.telefon,
      kayit.cookzoneIsletmeId ?? null,
    );
  }
}