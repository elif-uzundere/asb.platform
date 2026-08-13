import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/cookzone_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../../domain/cookzone_kurallari.dart';
import '../durum/cookzone_siparislerim_durumu.dart';

class CookzoneSiparislerimEkrani extends ConsumerWidget {
  const CookzoneSiparislerimEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(cookzoneSiparislerimProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Cookzone Siparişlerim'),
        backgroundColor: Renkler.beyaz,
        foregroundColor: Renkler.lacivert,
        elevation: 0,
      ),
      body: durum.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$hata', textAlign: TextAlign.center, style: const TextStyle(color: Renkler.metinIkincil)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.invalidate(cookzoneSiparislerimProvider),
                  child: const Text('Tekrar dene'),
                ),
              ],
            ),
          ),
        ),
        data: (siparisler) {
          if (siparisler.isEmpty) {
            return const Center(
              child: Text('Henüz Cookzone siparişiniz yok', style: TextStyle(color: Renkler.metinIkincil)),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(cookzoneSiparislerimProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: siparisler.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _SiparisKarti(siparis: siparisler[index]),
            ),
          );
        },
      ),
    );
  }
}

class _SiparisKarti extends StatelessWidget {
  const _SiparisKarti({required this.siparis});

  final CookzoneSiparisResponse siparis;

  @override
  Widget build(BuildContext context) {
    final renk = _durumRengi(siparis.durum);
    final ozet = siparis.kalemler.map((k) => '${k.adet}× ${k.menuOgesiAdi}').join(', ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Renkler.lacivert.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(siparis.isletmeAdi, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Renkler.lacivert)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: renk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(durumEtiketi(siparis.durum), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: renk)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(ozet, style: const TextStyle(fontSize: 12.5, color: Renkler.metinIkincil)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 13, color: Renkler.metinIkincil),
              const SizedBox(width: 4),
              Text('Alınma: ${tarihSaatiFormatla(siparis.alinmaSaati)}', style: const TextStyle(fontSize: 11.5, color: Renkler.metinIkincil)),
              const Spacer(),
              Text('${siparis.toplamTutar} ₺', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Renkler.mavi)),
            ],
          ),
        ],
      ),
    );
  }

  Color _durumRengi(CookzoneSiparisDurumu durum) => switch (durum) {
        CookzoneSiparisDurumu.beklemede => Renkler.altin,
        CookzoneSiparisDurumu.alindi => Renkler.mavi,
        CookzoneSiparisDurumu.hazirlaniyor => Renkler.mavi,
        CookzoneSiparisDurumu.hazir => const Color(0xFF16A34A),
        CookzoneSiparisDurumu.teslimEdildi => Renkler.metinIkincil,
      };
}
