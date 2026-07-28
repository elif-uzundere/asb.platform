// Kaynak: eski Expo src/core/stores/auth.store.ts içindeki `guvenliDepo` (silindi — bkz. izlence Ek A)
// (expo-secure-store / web'de localStorage) karşılığı.
// Flutter tarafında flutter_secure_storage her iki platformu da kendisi soyutluyor.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GuvenliDepo {
  GuvenliDepo([FlutterSecureStorage? depo])
      : _depo = depo ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _depo;

  /// Zustand persist'in kullandığı anahtarla aynı tutuldu.
  static const String authAnahtari = 'asb-auth';

  Future<String?> oku(String anahtar) => _depo.read(key: anahtar);

  Future<void> yaz(String anahtar, String deger) =>
      _depo.write(key: anahtar, value: deger);

  Future<void> sil(String anahtar) => _depo.delete(key: anahtar);
}

final guvenliDepoProvider = Provider<GuvenliDepo>((ref) => GuvenliDepo());
