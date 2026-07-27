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
  rol: KullaniciRolu;
  firmaId: string | null;
  epostaDogrulandi: boolean;
}

export interface LoginResponse {
  accessToken: string;
  kullanici: KullaniciOzet;
}