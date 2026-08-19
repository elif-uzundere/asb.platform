import type { YetkiKodu } from './yetki.types';

export type KullaniciRolu =
  | 'ziyaretci'
  | 'firma_calisani'
  | 'firma_yetkilisi'
  | 'admin'
  | 'cookzone_yetkilisi'
  | 'palet_tesisi_yetkilisi'
  | 'itfaiye_ekibi'
  | 'guvenlik_ekibi'
  | 'tekin_isg_ekibi'
  | 'kantar_ekibi'
  | 'gumruk_ekibi'
  | 'sirket_isg_ekibi';

export interface RegisterRequest {
  ad: string;
  soyad: string;
  email: string;
  sifre: string;       // min 8 karakter, en az 1 rakam — validasyon backend'de (US-001 kabul kriteri)
  telefon?: string;     // opsiyonel, şemada nullable
}

export interface LoginRequest {
  email: string;
  sifre: string;
  beniHatirla?: boolean;
}

export interface KullaniciOzet {
  id: string;
  ad: string;
  soyad: string;
  email: string;
  telefon: string | null;
  rol: KullaniciRolu;
  firmaId: string | null;
  /** Sadece rol = cookzone_yetkilisi olan hesaplarda dolu. */
  cookzoneIsletmeId: string | null;
  epostaDogrulandi: boolean;
  /** `rol`e admin panelinden (RolYetki) tanımlı yetki kodları — 18.08.2026,
   * Berzan'ın isteği: uygulama "kim yapabilir" kararını sabit rol
   * kontrolüyle değil bu listeyle vermeli (ör. İkinci El ilan girme). */
  yetkiler: YetkiKodu[];
}

export interface LoginResponse {
  accessToken: string;
  kullanici: KullaniciOzet;
}

export interface SifremiUnuttumRequest {
  email: string;
}

export interface SifreSifirlaRequest {
  token: string;
  yeniSifre: string;
}

export interface SifreDegistirRequest {
  mevcutSifre: string;
  yeniSifre: string;
}

export interface EpostaDegistirRequest {
  yeniEposta: string;
  mevcutSifre: string;
}

export interface ProfilGuncelleRequest {
  ad: string;
  soyad: string;
  telefon?: string;
}

export interface GoogleGirisRequest {
  /** Google Identity Services'in ürettiği ID token — backend'de
   * google-auth-library ile doğrulanır. */
  idToken: string;
}