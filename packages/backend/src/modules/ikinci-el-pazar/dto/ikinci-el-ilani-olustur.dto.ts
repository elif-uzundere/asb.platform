import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsNotEmpty,
  IsNumber,
  IsString,
  IsUrl,
  MaxLength,
  Min,
} from 'class-validator';

/**
 * POST /ikinci-el-pazar isteğinde Flutter'ın göndereceği alanlar.
 *
 * kullaniciId burada bulunmaz:
 * giriş yapan kullanıcının JWT bilgisinden alınır.
 *
 * sehir burada bulunmaz:
 * backend tarafından otomatik olarak "Tekirdağ / Çorlu" atanır.
 */
export class IkinciElIlaniOlusturDto {
  @IsString({
    message: 'İlan başlığı metin olmalıdır',
  })
  @IsNotEmpty({
    message: 'İlan başlığı boş bırakılamaz',
  })
  @MaxLength(150, {
    message: 'İlan başlığı en fazla 150 karakter olabilir',
  })
  baslik!: string;

  @IsString({
    message: 'İlan açıklaması metin olmalıdır',
  })
  @IsNotEmpty({
    message: 'İlan açıklaması boş bırakılamaz',
  })
  aciklama!: string;

  @IsNumber(
    {},
    {
      message: 'Fiyat sayısal bir değer olmalıdır',
    },
  )
  @Min(1, {
    message: 'Fiyat en az 1 olmalıdır',
  })
  fiyat!: number;

  @IsString({
    message: 'Kategori metin olmalıdır',
  })
  @IsNotEmpty({
    message: 'Kategori seçilmelidir',
  })
  @MaxLength(80, {
    message: 'Kategori en fazla 80 karakter olabilir',
  })
  kategori!: string;

  @IsString({
    message: 'Ürün durumu metin olmalıdır',
  })
  @IsNotEmpty({
    message: 'Ürün durumu seçilmelidir',
  })
  @MaxLength(50, {
    message: 'Ürün durumu en fazla 50 karakter olabilir',
  })
  urunDurumu!: string;

  @IsArray({
    message: 'Fotoğraflar liste biçiminde gönderilmelidir',
  })
  @ArrayMinSize(1, {
    message: 'En az bir fotoğraf eklenmelidir',
  })
  @ArrayMaxSize(10, {
    message: 'En fazla 10 fotoğraf eklenebilir',
  })
  @IsUrl(
    {},
    {
      each: true,
      message: 'Fotoğraf bağlantıları geçerli olmalıdır',
    },
  )
  fotografUrls!: string[];
}