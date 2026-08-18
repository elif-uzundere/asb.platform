import type { KullaniciRolu } from '@asb/shared-types';
import { AcilDurumTuru } from './acil-durum-bildirimi';

/**
 * Her bildirim türünün hangi ekibe düştüğü (14.08.2026, Berzan'ın kararı).
 *
 * `saglik` ≠ `diger`: sağlık türü DIŞ/anlaşmalı bir firmaya (Tekin İSG)
 * gider, diğer türü ASB'nin KENDİ iç İSG ekibine gider — ikisi birbirine
 * karıştırılmaması gereken, kasıtlı olarak ayrı iki rol/hesap.
 */
export const ACIL_DURUM_TUR_EKIP_ESLEME: Record<AcilDurumTuru, KullaniciRolu> = {
  yangin: 'itfaiye_ekibi',
  kaza: 'guvenlik_ekibi',
  saglik: 'tekin_isg_ekibi',
  kantar: 'kantar_ekibi',
  gumruk: 'gumruk_ekibi',
  diger: 'sirket_isg_ekibi',
};
