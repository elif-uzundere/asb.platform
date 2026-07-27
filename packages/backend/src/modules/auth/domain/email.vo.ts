import { GecersizEmailException } from './auth.exceptions';

export class Email {
  private readonly deger: string;

  constructor(deger: string) {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!regex.test(deger)) {
      throw new GecersizEmailException(deger);
    }
    this.deger = deger.toLowerCase();
  }

  toString(): string {
    return this.deger;
  }
}