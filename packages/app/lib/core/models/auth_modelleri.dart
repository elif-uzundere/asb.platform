// Kaynak: packages/shared-types/src/auth.types.ts
//
// packages/shared-types bir TypeScript paketi ve Dart'tan import edilemiyor;
// bu yüzden tipler burada EL İLE yansıtılıyor (manuel mirror).
// TS tarafı değişirse bu dosya da aynı PR'da güncellenmeli.
// Karar kaydı: docs/CLAUDE.md → "Alınan Kararlar", 27.07.2026.

/// TS: `export type KullaniciRolu = 'ziyaretci' | 'firma_calisani' | ...`
enum KullaniciRolu {
  ziyaretci('ziyaretci'),
  firmaCalisani('firma_calisani'),
  firmaYetkilisi('firma_yetkilisi'),
  admin('admin');

  const KullaniciRolu(this.deger);

  /// Backend'in JSON'da gönderdiği string karşılığı.
  final String deger;

  static KullaniciRolu cozumle(String? deger) => KullaniciRolu.values.firstWhere(
        (rol) => rol.deger == deger,
        orElse: () => KullaniciRolu.ziyaretci,
      );
}

/// TS: `interface RegisterRequest`
class RegisterRequest {
  const RegisterRequest({
    required this.ad,
    required this.soyad,
    required this.email,
    required this.sifre,
    this.telefon,
  });

  final String ad;
  final String soyad;
  final String email;

  /// min 8 karakter, en az 1 rakam — asıl validasyon backend'de (US-001).
  final String sifre;

  /// Opsiyonel, şemada nullable.
  final String? telefon;

  Map<String, dynamic> jsonaDonustur() => {
        'ad': ad,
        'soyad': soyad,
        'email': email,
        'sifre': sifre,
        if (telefon != null && telefon!.isNotEmpty) 'telefon': telefon,
      };
}

/// TS: `interface LoginRequest`
class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.sifre,
    this.beniHatirla,
  });

  final String email;
  final String sifre;

  /// true ise backend 30 gün, aksi halde 1 gün geçerli token üretir.
  final bool? beniHatirla;

  Map<String, dynamic> jsonaDonustur() => {
        'email': email,
        'sifre': sifre,
        if (beniHatirla != null) 'beniHatirla': beniHatirla,
      };
}

/// TS: `interface KullaniciOzet`
class KullaniciOzet {
  const KullaniciOzet({
    required this.id,
    required this.ad,
    required this.soyad,
    required this.email,
    required this.telefon,
    required this.rol,
    required this.firmaId,
    required this.epostaDogrulandi,
  });

  final String id;
  final String ad;
  final String soyad;
  final String email;
  final String? telefon;
  final KullaniciRolu rol;
  final String? firmaId;
  final bool epostaDogrulandi;

  String get tamAd => '$ad $soyad';

  KullaniciOzet kopyala({String? email}) => KullaniciOzet(
        id: id,
        ad: ad,
        soyad: soyad,
        email: email ?? this.email,
        telefon: telefon,
        rol: rol,
        firmaId: firmaId,
        epostaDogrulandi: email != null ? false : epostaDogrulandi,
      );

  factory KullaniciOzet.jsondan(Map<String, dynamic> json) => KullaniciOzet(
        id: json['id'] as String,
        ad: json['ad'] as String,
        soyad: json['soyad'] as String,
        email: json['email'] as String,
        telefon: json['telefon'] as String?,
        rol: KullaniciRolu.cozumle(json['rol'] as String?),
        firmaId: json['firmaId'] as String?,
        epostaDogrulandi: json['epostaDogrulandi'] as bool? ?? false,
      );

  Map<String, dynamic> jsonaDonustur() => {
        'id': id,
        'ad': ad,
        'soyad': soyad,
        'email': email,
        'telefon': telefon,
        'rol': rol.deger,
        'firmaId': firmaId,
        'epostaDogrulandi': epostaDogrulandi,
      };
}

/// TS: `interface LoginResponse` — /auth/login ve /auth/register'ın `data` alanı.
class LoginResponse {
  const LoginResponse({required this.accessToken, required this.kullanici});

  final String accessToken;
  final KullaniciOzet kullanici;

  factory LoginResponse.jsondan(Map<String, dynamic> json) => LoginResponse(
        accessToken: json['accessToken'] as String,
        kullanici:
            KullaniciOzet.jsondan(json['kullanici'] as Map<String, dynamic>),
      );
}

/// TS: `interface SifremiUnuttumRequest`
class SifremiUnuttumRequest {
  const SifremiUnuttumRequest({required this.email});

  final String email;

  Map<String, dynamic> jsonaDonustur() => {'email': email};
}

/// TS: `interface SifreSifirlaRequest`
class SifreSifirlaRequest {
  const SifreSifirlaRequest({required this.token, required this.yeniSifre});

  final String token;
  final String yeniSifre;

  Map<String, dynamic> jsonaDonustur() => {
        'token': token,
        'yeniSifre': yeniSifre,
      };
}

/// TS: `interface SifreDegistirRequest`
class SifreDegistirRequest {
  const SifreDegistirRequest({required this.mevcutSifre, required this.yeniSifre});

  final String mevcutSifre;
  final String yeniSifre;

  Map<String, dynamic> jsonaDonustur() => {
        'mevcutSifre': mevcutSifre,
        'yeniSifre': yeniSifre,
      };
}

/// TS: `interface EpostaDegistirRequest`
class EpostaDegistirRequest {
  const EpostaDegistirRequest({required this.yeniEposta, required this.mevcutSifre});

  final String yeniEposta;
  final String mevcutSifre;

  Map<String, dynamic> jsonaDonustur() => {
        'yeniEposta': yeniEposta,
        'mevcutSifre': mevcutSifre,
      };
}

/// TS: `interface ProfilGuncelleRequest`
class ProfilGuncelleRequest {
  const ProfilGuncelleRequest({required this.ad, required this.soyad, this.telefon});

  final String ad;
  final String soyad;
  final String? telefon;

  Map<String, dynamic> jsonaDonustur() => {
        'ad': ad,
        'soyad': soyad,
        if (telefon != null && telefon!.isNotEmpty) 'telefon': telefon,
      };
}
