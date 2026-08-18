import { Type } from 'class-transformer';
import {
  IsNotEmpty,
  IsNumber,
  IsString,
  Matches,
  MaxLength,
  Min,
} from 'class-validator';

/**
 * POST /ikinci-el-pazar isteğinde Flutter'ın göndereceği alanlar.
 *
 * `multipart/form-data` gövdesi — fotoğraflar ayrı dosya alanları
 * (@UploadedFiles), bu DTO sadece metin alanlarını temsil eder. `fiyat`
 * multipart'ta string olarak gelir, @Type(() => Number) ile dönüştürülür
 * (bkz. main.ts'teki ValidationPipe transform:true).
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

  @Type(() => Number)
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

  @IsString({
    message: 'İletişim telefonu metin olmalıdır',
  })
  @IsNotEmpty({
    message: 'İletişim telefonu zorunludur',
  })
  @Matches(/^[0-9+() -]{10,20}$/, {
    message: 'İletişim telefonu geçerli bir numara olmalıdır',
  })
  iletisimTelefonu!: string;
}
