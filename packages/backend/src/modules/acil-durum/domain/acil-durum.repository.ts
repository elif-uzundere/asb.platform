import { AcilDurumBilgisi } from './acil-durum-birimi';
import { ToplanmaAlani } from './toplanma-alani';

export abstract class AcilDurumRepository {
  abstract bilgileriGetir(): Promise<AcilDurumBilgisi[]>;

  abstract toplanmaAlanlariniGetir(): Promise<ToplanmaAlani[]>;
}