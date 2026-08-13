// cookzone_yetkilisi'nin sipariş kuyruğu — kabul et / hazırlanıyor / hazır /
// teslim edildi tek bir "İlerlet" butonuyla, sırada ne olduğu domain
// kuralından (ilerletmeButonuEtiketi) geliyor.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/cookzone_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../../domain/cookzone_kurallari.dart';
import '../durum/cookzone_isletme_siparisleri_durumu.dart';
import '../durum/cookzone_siparis_ilerlet_notifier.dart';

class CookzoneIsletmeSiparisleriEkrani extends ConsumerWidget {
  const CookzoneIsletmeSiparisleriEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(cookzoneIsletmeSiparisleriProvider);

    ref.listen<IslemDurumu>(cookzoneSiparisIlerletNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Sipariş ilerletilemedi',
        sifirla: ref.read(cookzoneSiparisIlerletNotifierProvider.notifier).sifirla,
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Sipariş Kuyruğu'),
        backgroundColor: Renkler.beyaz,
        foregroundColor: Renkler.lacivert,
        elevation: 0,
      ),
      body: durum.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$hata', textAlign: TextAlign.center, style: const TextStyle(color: Renkler.metinIkincil)),
          ),
        ),
        data: (siparisler) {
          if (siparisler.isEmpty) {
            return const Center(child: Text('Kuyrukta sipariş yok', style: TextStyle(color: Renkler.metinIkincil)));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(cookzoneIsletmeSiparisleriProvider.future),
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

class _SiparisKarti extends ConsumerWidget {
  const _SiparisKarti({required this.siparis});

  final CookzoneSiparisYonetimResponse siparis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yukleniyor = ref.watch(cookzoneSiparisIlerletNotifierProvider) is IslemSuruyor;
    final sonrakiVarMi = sonrakiDurum(siparis.durum) != null;
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
                child: Text(siparis.kullaniciAdSoyad, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Renkler.lacivert)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Renkler.mavi.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(durumEtiketi(siparis.durum), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Renkler.mavi)),
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
          if (sonrakiVarMi) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: yukleniyor
                    ? null
                    : () => ref.read(cookzoneSiparisIlerletNotifierProvider.notifier).ilerlet(siparis.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Renkler.lacivert,
                  foregroundColor: Renkler.beyaz,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(ilerletmeButonuEtiketi(siparis.durum)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
