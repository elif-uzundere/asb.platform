// React Native'deki Alert.alert(baslik, mesaj) karşılığı.

import 'package:flutter/material.dart';

import '../theme/renkler.dart';

Future<void> bilgiPenceresiGoster(
  BuildContext context, {
  required String baslik,
  required String mesaj,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        baslik,
        style: const TextStyle(fontSize: 17, color: Renkler.lacivert),
      ),
      content: Text(mesaj, style: const TextStyle(fontSize: 14)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}
