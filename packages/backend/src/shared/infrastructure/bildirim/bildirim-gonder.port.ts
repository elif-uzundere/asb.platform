export const BILDIRIM_GONDER_PORT = Symbol('BILDIRIM_GONDER_PORT');

/**
 * `EmailGonderPort` ile aynı gerekçeyle tasarlandı: çağıran taraf (örn.
 * `CookzoneService`) sadece "bu kullanıcıya şunu bildir" der, push
 * altyapısının nasıl çalıştığını (FCM, cihaz token'ları vb.) bilmez —
 * o detay adapter'ın içinde saklı.
 */
export interface BildirimGonderPort {
  /** `veri`, bildirime tıklandığında uygulamanın hangi ekrana gideceğini
   * taşımak için (örn. `{ tur: 'cookzone_siparis', siparisId: '...' }`). */
  gonder(
    kullaniciId: string,
    baslik: string,
    icerik: string,
    veri?: Record<string, string>,
  ): Promise<void>;
}
