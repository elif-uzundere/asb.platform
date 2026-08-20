import type { KullaniciRolu } from '@asb/shared-types';
import { AcilDurumTuru } from './acil-durum-bildirimi';

/**
 * Her bildirim türünün hangi ekibe düştüğünü tanımlar.
 *
 * `saglik` ile `diger` farklı: sağlık türü dış/anlaşmalı bir firmaya
 * (Tekin İSG) gider. Diğer türü ASB'nin kendi iç İSG ekibine gider.
 * İkisi birbirine karıştırılmamalı, kasıtlı olarak ayrı iki rol/hesap.
 */
export const ACIL_DURUM_TUR_EKIP_ESLEME: Record<AcilDurumTuru, KullaniciRolu> = {
  yangin: 'itfaiye_ekibi',
  kaza: 'guvenlik_ekibi',
  saglik: 'tekin_isg_ekibi',
  kantar: 'kantar_ekibi',
  gumruk: 'gumruk_ekibi',
  diger: 'sirket_isg_ekibi',
};
