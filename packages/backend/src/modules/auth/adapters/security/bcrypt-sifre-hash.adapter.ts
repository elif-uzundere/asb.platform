import { Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { SifreHashPort } from '../../domain';

const TUR_SAYISI = 10;

@Injectable()
export class BcryptSifreHashAdapter implements SifreHashPort {
  async hashle(duzMetin: string): Promise<string> {
    return bcrypt.hash(duzMetin, TUR_SAYISI);
  }

  async dogrula(duzMetin: string, hash: string): Promise<boolean> {
    return bcrypt.compare(duzMetin, hash);
  }
}