export type AcilDurumTuru = 'yangin' | 'kaza' | 'saglik' | 'kantar' | 'gumruk' | 'diger';

export type AcilDurumBildirimDurumu = 'yeni' | 'inceleniyor' | 'kapatildi';

export interface AcilDurumBildirimiResponse {
  id: string;
  tur: AcilDurumTuru;
  aciklama: string | null;
  durum: AcilDurumBildirimDurumu;
  olusturmaTarihi: string;
}

/** `POST /acil-durum/bildirimler` — konum BİLEREK yok (harita modülü kapsam dışı). */
export interface AcilDurumBildirimiOlusturRequest {
  tur: AcilDurumTuru;
  aciklama: string;
}

/**
 * `GET /acil-durum/ekip/bildirimler` — ilgili ekibin (itfaiye_ekibi,
 * guvenlik_ekibi, tekin_isg_ekibi, kantar_ekibi, gumruk_ekibi,
 * sirket_isg_ekibi) kendi türüne düşen bildirimleri görme görünümü.
 * `AcilDurumBildirimiResponse`'tan farkı: bildiren kişinin adı burada var.
 */
export interface EkibeGelenBildirimResponse {
  id: string;
  tur: AcilDurumTuru;
  aciklama: string | null;
  durum: AcilDurumBildirimDurumu;
  bildirenAdSoyad: string;
  olusturmaTarihi: string;
}

/** `PUT /acil-durum/ekip/bildirimler/:id/durum` — `yeni` BİLEREK yok, geri dönüş desteklenmiyor. */
export interface AcilDurumBildirimDurumGuncelleRequest {
  durum: Exclude<AcilDurumBildirimDurumu, 'yeni'>;
}
