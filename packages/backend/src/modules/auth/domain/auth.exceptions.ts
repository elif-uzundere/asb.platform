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