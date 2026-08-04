// Kaynak (UX/metin/iş kuralı): eski Expo app/(tabs)/profil.tsx (silindi — bkz. docs/izlence-typescript-nestjs(1).md Ek A)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';
import '../durum/auth_durumu.dart';

class ProfilEkrani extends ConsumerWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kullanici = ref.watch(authProvider).kullanici;

    // '/profil' BİLEREK açık rota (bkz. yonlendirici.dart) — Ana Sayfa'nın
    // kendi Giriş Yap/Kayıt Ol daveti kaldırıldığından bu dal artık asıl akış:
    // oturumsuz kullanıcı sekmeye basınca burada karşılanıyor.
    if (kullanici == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Profil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Devam etmek için giriş yapın.',
                style: TextStyle(color: Renkler.metinIkincil),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/giris'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Renkler.altin,
                  foregroundColor: Renkler.lacivert,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/kayit'),
                child: const Text('Hesabın yok mu? Kayıt Ol'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kullanici.tamAd,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Renkler.lacivert,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                kullanici.email,
                style: const TextStyle(color: Renkler.metinIkincil),
              ),
              const SizedBox(height: 8),
              Text(
                'Rol: ${kullanici.rol.deger}',
                style: const TextStyle(color: Renkler.metinIkincil),
              ),
              if (!kullanici.epostaDogrulandi) ...[
                const SizedBox(height: 8),
                const Text(
                  'E-posta henüz doğrulanmadı',
                  style: TextStyle(color: Renkler.altin, fontSize: 12),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.read(authProvider.notifier).cikisYap(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Renkler.beyaz,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Çıkış Yap',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
