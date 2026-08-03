import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/duyuru_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../durum/duyuru_durumu.dart';

class DuyurularEkrani extends ConsumerWidget {
  const DuyurularEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(duyuruListesiProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Duyurular'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: durum.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => _HataGorunumu(
          mesaj: '$hata',
          tekrarDene: () => ref.invalidate(duyuruListesiProvider),
        ),
        data: (duyurular) => duyurular.isEmpty
            ? const _BosGorunum()
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(duyuruListesiProvider),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: duyurular.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _DuyuruKarti(
                    duyuru: duyurular[index],
                    tiklandi: () => context.push('/duyurular/${duyurular[index].id}'),
                  ),
                ),
              ),
      ),
    );
  }
}

class _DuyuruKarti extends StatelessWidget {
  const _DuyuruKarti({required this.duyuru, required this.tiklandi});

  final DuyuruResponse duyuru;
  final VoidCallback tiklandi;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.campaign_outlined),
        title: Text(duyuru.baslik),
        subtitle: Text(
          '${duyuru.kategori ?? 'Genel'} • ${_tarihiFormatla(duyuru.yayinTarihi)}\n${duyuru.icerik}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: tiklandi,
      ),
    );
  }
}

class _BosGorunum extends StatelessWidget {
  const _BosGorunum();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.campaign_outlined, size: 40, color: Renkler.metinIkincil),
          SizedBox(height: 12),
          Text('Henüz duyuru yok', style: TextStyle(color: Renkler.metinIkincil)),
        ],
      ),
    );
  }
}

class _HataGorunumu extends StatelessWidget {
  const _HataGorunumu({required this.mesaj, required this.tekrarDene});

  final String mesaj;
  final VoidCallback tekrarDene;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40, color: Renkler.metinIkincil),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              mesaj,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Renkler.metinIkincil),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: tekrarDene, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}

String _tarihiFormatla(DateTime tarih) {
  String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
  return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year}';
}
