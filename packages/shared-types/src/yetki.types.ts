/**
 * Sistemde tanımlı yetki kodları.
 *
 * Bu değerler kullanıcı tarafından serbestçe oluşturulmaz.
 * Uygulamanın desteklediği izin türlerini belirtir.
 */
export const YETKILER = {
  DUYURU_YONET: 'duyuru_yonet',
  IKINCI_EL_YONET: 'ikinci_el_yonet',
  IS_ILANI_YONET: 'is_ilani_yonet',
  COOKZONE_YONET: 'cookzone_yonet',
  PALET_TESISI_YONET: 'palet_tesisi_yonet',
} as const;

/**
 * YETKILER içinde bulunan değerlerden oluşan tip.
 */
export type YetkiKodu = (typeof YETKILER)[keyof typeof YETKILER];
