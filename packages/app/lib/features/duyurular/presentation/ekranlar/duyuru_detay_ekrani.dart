// Derin link için GET /duyurular/{id} kullanır (listeden taşınan nesneyle
// değil) — bkz. firma_detay_ekrani.dart başındaki aynı gerekçe / docs/CLAUDE.md
// derin link kararı.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/renkler.dart';
import '../durum/duyuru_durumu.dart';

class DuyuruDetayEkrani extends ConsumerWidget {
  const DuyuruDetayEkrani({super.key, required this.duyuruId});

  final String duyuruId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(duyuruDetayProvider(duyuruId));

    return Scaffold(
      appBar: AppBar(title: const Text('Duyuru Detayı')),
      body: durum.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '$hata',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Renkler.metinIkincil),
            ),
          ),
        ),
        data: (duyuru) => Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  duyuru.baslik,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  '${duyuru.kategori ?? 'Genel'} • ${_tarihiFormatla(duyuru.yayinTarihi)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Text(duyuru.icerik, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _tarihiFormatla(DateTime tarih) {
  String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
  return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year}';
}
