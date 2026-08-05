// Kaynak (davranış): eski Expo src/features/auth/auth.api.ts (silindi — bkz. docs/izlence-typescript-nestjs(1).md Ek A)
//
// Bu katmanın tek işi: HTTP çağrısını yapmak ve gövdeyi modele çevirmek.
// Zarf çözme / hata çevirme `apiIstegi` içinde ortak — burada tekrar edilmez.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/auth_modelleri.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_istegi.dart';

class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  Future<LoginResponse> girisYapIstegi(LoginRequest dto) => apiIstegi(
        () => _dio.post<Map<String, dynamic>>(
          '/auth/login',
          data: dto.jsonaDonustur(),
        ),
        cozumle: (veri) => LoginResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'E-posta veya şifre hatalı.',
      );

  Future<LoginResponse> kayitOlIstegi(RegisterRequest dto) => apiIstegi(
        () => _dio.post<Map<String, dynamic>>(
          '/auth/register',
          data: dto.jsonaDonustur(),
        ),
        cozumle: (veri) => LoginResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Bilgileri kontrol edin (şifre: en az 8 karakter, 1 rakam). '
            'E-posta zaten kayıtlı olabilir.',
      );

  Future<void> sifremiUnuttumIstegi(SifremiUnuttumRequest dto) =>
      apiIstegi<void>(
        () => _dio.post<Map<String, dynamic>>(
          '/auth/sifremi-unuttum',
          data: dto.jsonaDonustur(),
        ),
        // Bu endpoint `data: null` döner — çözülecek gövde yok.
        cozumle: (_) {},
        yedekMesaj: 'Bir şeyler ters gitti, tekrar dene.',
      );

  Future<void> sifreSifirlaIstegi(SifreSifirlaRequest dto) => apiIstegi<void>(
        () => _dio.post<Map<String, dynamic>>(
          '/auth/sifre-sifirla',
          data: dto.jsonaDonustur(),
        ),
        cozumle: (_) {},
        yedekMesaj: 'Link geçersiz/süresi dolmuş olabilir ya da şifre kuralına '
            'uymuyor (min 8 karakter, 1 rakam).',
      );

  Future<LoginResponse> googleIleGirisIstegi(GoogleGirisRequest dto) => apiIstegi(
        () => _dio.post<Map<String, dynamic>>(
          '/auth/google-giris',
          data: dto.jsonaDonustur(),
        ),
        cozumle: (veri) => LoginResponse.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Google girişi başarısız, tekrar dene.',
      );

  Future<void> sifreDegistirIstegi(SifreDegistirRequest dto) => apiIstegi<void>(
        () => _dio.patch<Map<String, dynamic>>(
          '/auth/sifre-degistir',
          data: dto.jsonaDonustur(),
        ),
        cozumle: (_) {},
        yedekMesaj: 'Şifre değiştirilemedi, mevcut şifrenizi kontrol edin.',
      );

  Future<void> epostaDegistirIstegi(EpostaDegistirRequest dto) => apiIstegi<void>(
        () => _dio.patch<Map<String, dynamic>>(
          '/auth/eposta-degistir',
          data: dto.jsonaDonustur(),
        ),
        cozumle: (_) {},
        yedekMesaj: 'E-posta değiştirilemedi, mevcut şifrenizi kontrol edin.',
      );

  Future<KullaniciOzet> profilGuncelleIstegi(ProfilGuncelleRequest dto) => apiIstegi(
        () => _dio.patch<Map<String, dynamic>>(
          '/auth/profil',
          data: dto.jsonaDonustur(),
        ),
        cozumle: (veri) => KullaniciOzet.jsondan(veri! as Map<String, dynamic>),
        yedekMesaj: 'Profil güncellenemedi, bilgileri kontrol edin.',
      );
}

final authApiProvider =
    Provider<AuthApi>((ref) => AuthApi(ref.watch(apiClientProvider)));
