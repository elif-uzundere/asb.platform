/**
 * Uygulama içinde kullanılan ikinci el ilan verisi.
 *
 * Bu yapı Prisma'ya veya HTTP katmanına bağlı değildir.
 * Domain katmanı sadece ilan verisinin nasıl göründüğünü bilir.
 */
export interface IkinciElIlani {
  id: string;
  kullaniciId: string;
  baslik: string;
  aciklama: string;
  fiyat: number;
  kategori: string;
  urunDurumu: string;
  iletisimTelefonu: string;
  fotografUrls: string[];
  oneCikan: boolean;
  durum: 'aktif' | 'satildi' | 'pasif';
  firmaAdi: string;
  olusturmaTarihi: Date;
}

/**
 * Yeni ilan oluşturulurken repository'ye gönderilecek veri.
 *
 * id ve oluşturulma tarihi burada bulunmaz.
 * Bunları veritabanı oluşturur.
 */
export interface IkinciElIlaniOlusturmaVerisi {
  kullaniciId: string;
  baslik: string;
  aciklama: string;
  fiyat: number;
  kategori: string;
  urunDurumu: string;
  iletisimTelefonu: string;
  fotografUrls: string[];
}