import type { FavoriHedefTuru } from '@asb/shared-types';

/**
 * `favori` modülünün diğer modüllere açtığı port — is-ilanlari, bir ilanın
 * kaç kişi tarafından favorilendiğini göstermek için (bkz. IsIlaniResponse
 * `favoriSayisi`) favori modülünün domain/persistence katmanına doğrudan
 * erişemez (mimari kural 3), sadece bu dar arayüzü görür.
 */
export interface FavoriSorgulamaPort {
  sayiGetir(hedefTuru: FavoriHedefTuru, hedefId: string): Promise<number>;
}
