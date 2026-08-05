export type KullaniciRolu = 'ziyaretci' | 'firma_calisani' | 'firma_yetkilisi' | 'admin';

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
  epostaDogrulandi: boolean;
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