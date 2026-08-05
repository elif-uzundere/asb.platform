// Google'ın ID token'ını doğrulayıp içindeki kullanıcı bilgisini çıkaran
// portun sözleşmesi. TokenUreticiPort/EmailGonderPort ile AYNI desen:
// application katmanı "google-auth-library" gibi somut bir kütüphaneyi
// DEĞİL, bu arayüzü bilir — gerçek doğrulama adapters/security'de.

export interface GoogleKullaniciBilgisi {
  email: string;
  ad: string;
  soyad: string;
}

export interface GoogleTokenDogrulayiciPort {
  /** Token geçersiz/süresi dolmuşsa GecersizGoogleTokenException fırlatır. */
  dogrula(idToken: string): Promise<GoogleKullaniciBilgisi>;
}
