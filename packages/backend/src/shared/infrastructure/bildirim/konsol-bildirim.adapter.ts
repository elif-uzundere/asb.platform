import { Injectable, Logger } from '@nestjs/common';
import { BildirimGonderPort } from './bildirim-gonder.port';

/**
 * GEÇİCİ SAHTE İMPLEMENTASYON — Firebase Cloud Messaging kimlik bilgileri
 * (servis hesabı JSON'ı) henüz elimizde yok. Modül Geliştirme Protokolü'nün
 * (c) adımı: "bağımlı olduğun modül/servis henüz yoksa sahte implementasyon
 * yaz, kendi işine devam et" — bkz. docs/CLAUDE.md.
 *
 * Gerçek bildirim GÖNDERMEZ, sadece konsola yazar — böylece CookzoneService
 * gibi çağıranlar `BildirimGonderPort`'a karşı yazılıp test edilebiliyor.
 * Firebase kimlik bilgileri gelince bu, gerçek bir `FcmBildirimAdapter` ile
 * değiştirilecek (sadece `bildirim.module.ts`'teki `useFactory` değişir,
 * `BildirimGonderPort`'u kullanan hiçbir kod etkilenmez).
 */
@Injectable()
export class KonsolBildirimAdapter implements BildirimGonderPort {
  private readonly logger = new Logger('Bildirim (SAHTE)');

  async gonder(
    kullaniciId: string,
    baslik: string,
    icerik: string,
    veri?: Record<string, string>,
  ): Promise<void> {
    this.logger.log(
      `→ kullanici=${kullaniciId} | ${baslik} — ${icerik}${veri ? ` | veri=${JSON.stringify(veri)}` : ''}`,
    );
  }
}
