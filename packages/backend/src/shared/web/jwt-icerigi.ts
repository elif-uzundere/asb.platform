// Access token'ın İÇİNDE ne taşındığının sözleşmesi.
//
// Neden `shared` altında?
// Bu payload'ı `auth` modülü ÜRETİYOR (JwtTokenUreticiAdapter.uret), guard'lar
// ise OKUYOR. İki taraf da aynı şekli bilmek zorunda. Sözleşmeyi taraflardan
// birinin içine koysaydık diğeri onun iç detayına bağımlı olurdu — üstelik
// `.eslintrc.json` buna zaten izin vermiyor (`shared` sadece `shared`'ı görür).
//
// Bu, Dependency Inversion'ın somut hâli: guard "auth modülünü" değil,
// "bir token şeklini" bilir. auth modülü tamamen yeniden yazılsa bile, bu şekle
// uyduğu sürece guard'lar etkilenmez.

import type { KullaniciRolu } from '@asb/shared-types';

/** JWT payload'ı — `auth` modülü tokenı bu alanlarla imzalar. */
export interface JwtIcerigi {
  /** Kullanıcı id'si (JWT standardında "subject"). */
  sub: string;
  email: string;
  rol: KullaniciRolu;
  /**
   * Kullanıcının bağlı olduğu firma (firma_yetkilisi/firma_calisani için
   * dolu, ziyaretci/admin için null). `is-ilanlari` modülü BR-2'yi ("sadece
   * onaylı firma ilan yayınlayabilir") ve sahiplik kontrolünü ("bu ilan
   * gerçekten senin firmana mı ait") bu alan üzerinden, ekstra bir DB
   * sorgusuna gerek kalmadan yapabiliyor.
   */
  firmaId: string | null;
  /** Sadece rol = cookzone_yetkilisi olan hesaplarda dolu — `firmaId` ile
   * aynı gerekçe, Cookzone modülü sahiplik kontrolünü buradan yapar. */
  cookzoneIsletmeId: string | null;
}

/**
 * Guard'ın doğruladıktan sonra request'e eklediği kullanıcı bilgisi.
 * Controller'lar `@AktifKullaniciBilgisi()` ile bunu okur.
 *
 * `JwtIcerigi`'nden ayrı bir tip: orası "token'da ne yazıyor", burası
 * "uygulamada kim işlem yapıyor". `sub` yerine okunabilir `id` kullanıyoruz.
 */
export interface AktifKullanici {
  id: string;
  email: string;
  rol: KullaniciRolu;
  firmaId: string | null;
  cookzoneIsletmeId: string | null;
}
