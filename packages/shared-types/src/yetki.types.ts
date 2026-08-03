/**
 * Sistemde tanımlı yetki kodları.
 *
 * Bu değerler kullanıcı tarafından serbestçe oluşturulmaz.
 * Uygulamanın desteklediği izin türlerini belirtir.
 */
export const YETKILER = {
  DUYURU_YONET: 'duyuru_yonet',
} as const;

/**
 * YETKILER içinde bulunan değerlerden oluşan tip.
 *
 * Şu anda geçerli tek değer:
 * 'duyuru_yonet'
 */
export type YetkiKodu = (typeof YETKILER)[keyof typeof YETKILER];
