// taleplerim_ekrani.dart (destek modülü) ile aynı basit liste deseni —
// arama/filtre yok, sadece kişinin kendi başvurularının salt-okunur listesi.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/is_ilani_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../../domain/is_ilani_kurallari.dart';
import '../durum/basvurularim_durumu.dart';

class BasvurularimEkrani extends ConsumerWidget {
  const BasvurularimEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(basvurularimProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Başvurularım'),
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
                  onPressed: () => ref.invalidate(basvurularimProvider),
                  child: const Text('Tekrar dene'),
                ),
              ],
            ),
          ),
        ),
        data: (basvurular) {
          if (basvurular.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: Renkler.mavi.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.bookmark_border_rounded, size: 30, color: Renkler.mavi),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Henüz bir iş ilanına başvurmadınız',
                    style: TextStyle(color: Renkler.metinIkincil, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(basvurularimProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: basvurular.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final basvuru = basvurular[index];
                return _BasvurumKarti(
                  basvuru: basvuru,
                  tiklandi: () => context.push('/is-ilanlari/${basvuru.isIlaniId}'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _BasvurumKarti extends StatelessWidget {
  const _BasvurumKarti({required this.basvuru, required this.tiklandi});

  final BasvurumResponse basvuru;
  final VoidCallback tiklandi;

  @override
  Widget build(BuildContext context) {
    final renk = _durumRengi(basvuru.durum);

    return Material(
      color: Renkler.beyaz,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: tiklandi,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Renkler.lacivert.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Renkler.mavi.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.work_outline_rounded, color: Renkler.mavi, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      basvuru.isIlaniBasligi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Renkler.lacivert),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      basvuru.firmaAdi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: Renkler.metinIkincil),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: Renkler.metinIkincil),
                        const SizedBox(width: 4),
                        Text(
                          tarihiFormatla(basvuru.basvuruTarihi),
                          style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: renk.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  basvuruDurumuEtiketi(basvuru.durum),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: renk),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _durumRengi(IsBasvurusuDurumu durum) => switch (durum) {
        IsBasvurusuDurumu.beklemede => Renkler.altin,
        IsBasvurusuDurumu.incelendi => Renkler.mavi,
        IsBasvurusuDurumu.kabul => const Color(0xFF16A34A),
        IsBasvurusuDurumu.reddedildi => const Color(0xFFDC2626),
      };
}
