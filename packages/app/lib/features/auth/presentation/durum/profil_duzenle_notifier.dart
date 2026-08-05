// Profil Düzenle formunun iş mantığı. Backend güncellenmiş kullanıcıyı
// döndürüyor, auth durumu doğrudan onunla güncelleniyor.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/auth_modelleri.dart';
import '../../data/auth_api.dart';
import 'auth_durumu.dart';

class ProfilDuzenleNotifier extends FormNotifier {
  ProfilDuzenleNotifier(this._ref);

  final Ref _ref;

  Future<void> gonder({required String ad, required String soyad, String? telefon}) {
    return calistir(() async {
      final guncellenen = await _ref.read(authApiProvider).profilGuncelleIstegi(
            ProfilGuncelleRequest(ad: ad, soyad: soyad, telefon: telefon),
          );
      await _ref.read(authProvider.notifier).kullaniciyiGuncelle(guncellenen);
    });
  }
}

final profilDuzenleNotifierProvider =
    StateNotifierProvider.autoDispose<ProfilDuzenleNotifier, IslemDurumu>(
  ProfilDuzenleNotifier.new,
);
