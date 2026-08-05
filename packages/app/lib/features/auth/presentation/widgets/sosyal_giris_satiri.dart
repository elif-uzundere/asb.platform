// core/widgets/form_ogeleri.dart'taki eski SosyalGirisSatiri'nin yerini
// aldı — core, feature'lara bağımlı olamayacağı için (mimari kural) Google
// düğmesi burada, features/auth altında birleştiriliyor.

import 'package:flutter/material.dart';

import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import 'google_giris_dugmesi.dart';

class SosyalGirisSatiri extends StatelessWidget {
  const SosyalGirisSatiri({super.key, required this.yakindaMesaji});

  /// LinkedIn/Apple henüz bağlanmadı — Google'dan FARKLI olarak bu ikisi
  /// hâlâ "yakında" gösteriyor.
  final String yakindaMesaji;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'veya',
          style: TextStyle(fontSize: 12, color: Renkler.metinIkincil),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GoogleGirisDugmesi(),
            const SizedBox(width: 14),
            SosyalButon(
              icerik: const Text(
                'in',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Renkler.lacivert,
                ),
              ),
              basildi: () => _yakinda(context),
            ),
            const SizedBox(width: 14),
            SosyalButon(
              icerik: const Icon(Icons.apple, size: 18, color: Renkler.lacivert),
              basildi: () => _yakinda(context),
            ),
          ],
        ),
      ],
    );
  }

  void _yakinda(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(yakindaMesaji)));
  }
}
