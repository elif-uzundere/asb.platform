import type { KullaniciRolu } from '@asb/shared-types';

/**
 * `auth` modülünün diğer modüllere açtığı ilk public port — firma
 * modülündeki `firma-sorgulama.port.ts` ile aynı gerekçe: `is-ilanlari`
 * başvuru listesinde "kim başvurdu" göstermek için `kullanici` tablosuna
 * doğrudan erişemez (mimari kural 3), sadece bu dar arayüzü görür.
 */
export interface KullaniciSorgulamaPort {
  /** Başvuru/ilan listelerinde görüntülemek için ad soyad. Kullanıcı yoksa null. */
  adSoyadGetir(kullaniciId: string): Promise<string | null>;

  /** Bir role sahip tüm kullanıcıların id+ad soyad'ı — Acil Durum bildirimini ilgili ekibin tamamına yönlendirmek için. */
  rolIleKullanicilariGetir(rol: KullaniciRolu): Promise<{ id: string; adSoyad: string }[]>;

  /** Bir Cookzone işletmesine bağlı cookzone_yetkilisi hesapları — yeni sipariş bildirimini yönlendirmek için. */
  cookzoneIsletmesineGoreKullanicilariGetir(isletmeId: string): Promise<{ id: string; adSoyad: string }[]>;
}
