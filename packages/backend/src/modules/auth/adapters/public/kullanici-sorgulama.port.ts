/**
 * `auth` modülünün diğer modüllere açtığı ilk public port — firma
 * modülündeki `firma-sorgulama.port.ts` ile aynı gerekçe: `is-ilanlari`
 * başvuru listesinde "kim başvurdu" göstermek için `kullanici` tablosuna
 * doğrudan erişemez (mimari kural 3), sadece bu dar arayüzü görür.
 */
export interface KullaniciSorgulamaPort {
  /** Başvuru/ilan listelerinde görüntülemek için ad soyad. Kullanıcı yoksa null. */
  adSoyadGetir(kullaniciId: string): Promise<string | null>;
}
