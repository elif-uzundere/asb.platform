// Form notifier'larının yaydığı [IslemDurumu]'nu kullanıcıya gösterme biçimi.
// Tek yerde durur ki her ekran kendi try/catch + dialog kodunu yazmasın.

import 'package:flutter/material.dart';

import '../durum/islem_durumu.dart';
import 'bilgi_penceresi.dart';

Future<void> islemGeriBildirimi(
  BuildContext context,
  IslemDurumu durum, {
  required String hataBasligi,
  required VoidCallback sifirla,
  String? basariBasligi,
  String? basariMesaji,
  VoidCallback? basariSonrasi,
}) async {
  switch (durum) {
    case IslemHatali(:final mesaj):
      await bilgiPenceresiGoster(context, baslik: hataBasligi, mesaj: mesaj);
      sifirla();

    case IslemBasarili():
      if (basariBasligi != null && basariMesaji != null) {
        await bilgiPenceresiGoster(
          context,
          baslik: basariBasligi,
          mesaj: basariMesaji,
        );
      }
      sifirla();
      // Dialog kapanana kadar ekran ağaçtan kalkmış olabilir.
      if (!context.mounted) return;
      basariSonrasi?.call();

    case IslemBosta():
    case IslemSuruyor():
      break;
  }
}
