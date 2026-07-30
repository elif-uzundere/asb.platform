import 'package:flutter/material.dart';

class DuyuruDetayEkrani extends StatelessWidget {
  const DuyuruDetayEkrani({
    super.key,
    required this.baslik,
    required this.icerik,
    required this.kategori,
    required this.tarih,
  });

  final String baslik;
  final String icerik;
  final String kategori;
  final String tarih;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duyuru Detayı'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baslik,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$kategori • $tarih',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Text(
              icerik,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}