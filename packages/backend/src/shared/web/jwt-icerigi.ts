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
}
