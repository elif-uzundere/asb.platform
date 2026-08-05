export class GecersizEmailException extends Error {
  constructor(deger: string) {
    super(`Geçersiz e-posta formatı: ${deger}`);
  }
}

export class EmailZatenKayitliException extends Error {
  constructor(email: string) {
    super(`Bu e-posta zaten kayıtlı: ${email}`);
  }
}

export class GecersizKimlikBilgisiException extends Error {
  constructor() {
    super('E-posta veya şifre hatalı');
  }
}
export class GecersizSifirlamaTokenException extends Error {
  constructor() {
    super('Şifre sıfırlama linki geçersiz veya süresi dolmuş');
  }
}

export class MevcutSifreYanlisException extends Error {
  constructor() {
    super('Mevcut şifreniz hatalı');
  }
}

/** Google/Apple gibi sosyal girişle açılan hesaplarda şifre yok — bu
 * hesaplar şifreyle giriş/değiştirme akışını kullanamaz. */
export class SifresizHesapException extends Error {
  constructor() {
    super('Bu hesapta şifre tanımlı değil, sosyal girişle devam edin');
  }
}

export class GecersizGoogleTokenException extends Error {
  constructor() {
    super('Google girişi doğrulanamadı, lütfen tekrar deneyin');
  }
}