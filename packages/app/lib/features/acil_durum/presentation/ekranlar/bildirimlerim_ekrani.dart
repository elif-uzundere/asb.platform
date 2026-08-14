import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/acil_durum_bildirimi.dart';
import '../durum/acil_durum_bildirimi_durumu.dart';

class BildirimlerimEkrani extends ConsumerWidget {
  const BildirimlerimEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(bildirimlerimProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102F68),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text(
          'Bildirimlerim',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: durum.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$hata', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF667085))),
          ),
        ),
        data: (bildirimler) {
          if (bildirimler.isEmpty) {
            return const Center(
              child: Text('Henüz bir bildiriminiz yok', style: TextStyle(color: Color(0xFF667085))),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: bildirimler.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _BildirimKarti(bildirim: bildirimler[index]),
          );
        },
      ),
    );
  }
}

class _BildirimKarti extends StatelessWidget {
  const _BildirimKarti({required this.bildirim});

  final AcilDurumBildirimiResponse bildirim;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7E9EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  bildirim.tur.etiket,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _durumRengi(bildirim.durum).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bildirim.durum.etiket,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _durumRengi(bildirim.durum)),
                ),
              ),
            ],
          ),
          if (bildirim.aciklama != null && bildirim.aciklama!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bildirim.aciklama!,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF344054), height: 1.4),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _tarihiFormatla(bildirim.olusturmaTarihi),
            style: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
          ),
        ],
      ),
    );
  }

  Color _durumRengi(AcilDurumBildirimDurumu durum) => switch (durum) {
        AcilDurumBildirimDurumu.yeni => const Color(0xFFF59E0B),
        AcilDurumBildirimDurumu.inceleniyor => const Color(0xFF1E7FD8),
        AcilDurumBildirimDurumu.kapatildi => const Color(0xFF16A34A),
      };

  String _tarihiFormatla(DateTime tarih) {
    String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
    return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year} ${ikiHane(tarih.hour)}:${ikiHane(tarih.minute)}';
  }
}
