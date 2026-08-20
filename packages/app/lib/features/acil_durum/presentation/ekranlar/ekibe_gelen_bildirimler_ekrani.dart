// Acil Durum ekiplerinin (itfaiye_ekibi, guvenlik_ekibi, tekin_isg_ekibi,
// kantar_ekibi, gumruk_ekibi, sirket_isg_ekibi) kendi türüne düşen
// bildirimleri gördüğü ve durumunu güncellediği ekran. Cookzone/Palet
// Tesisi'ndeki "ayrı yönetim ekranı" ile aynı desen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../../domain/acil_durum_bildirimi.dart';
import '../durum/acil_durum_bildirimi_durumu.dart';

class EkibeGelenBildirimlerEkrani extends ConsumerWidget {
  const EkibeGelenBildirimlerEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(ekibeGelenBildirimlerProvider);

    ref.listen<IslemDurumu>(acilDurumBildirimDurumGuncelleNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Bildirim güncellenemedi',
        sifirla: ref.read(acilDurumBildirimDurumGuncelleNotifierProvider.notifier).sifirla,
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102F68),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text(
          'Gelen Bildirimler',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(ekibeGelenBildirimlerProvider.future),
        child: durum.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (hata, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('$hata', textAlign: TextAlign.center),
              ),
            ],
          ),
          data: (bildirimler) {
            if (bildirimler.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('Henüz size gelen bir bildirim yok.')),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: bildirimler.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _BildirimKarti(bildirim: bildirimler[index]),
            );
          },
        ),
      ),
    );
  }
}

class _BildirimKarti extends ConsumerWidget {
  const _BildirimKarti({required this.bildirim});

  final EkibeGelenBildirimResponse bildirim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yukleniyor = ref.watch(acilDurumBildirimDurumGuncelleNotifierProvider) is IslemSuruyor;

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
                  bildirim.bildirenAdSoyad,
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
          const SizedBox(height: 4),
          Text(
            _tarihiFormatla(bildirim.olusturmaTarihi),
            style: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
          ),
          if (bildirim.aciklama != null && bildirim.aciklama!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bildirim.aciklama!,
              style: const TextStyle(fontSize: 12.5, color: Color(0xFF344054), height: 1.4),
            ),
          ],
          if (bildirim.durum != AcilDurumBildirimDurumu.kapatildi) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AcilDurumKarari.values
                  .where((karar) => karar.deger != bildirim.durum.deger)
                  .map((karar) {
                return OutlinedButton(
                  onPressed: yukleniyor
                      ? null
                      : () => ref
                          .read(acilDurumBildirimDurumGuncelleNotifierProvider.notifier)
                          .guncelle(bildirim.id, karar),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: karar == AcilDurumKarari.kapatildi
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF1E7FD8),
                    side: BorderSide(
                      color: karar == AcilDurumKarari.kapatildi
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF1E7FD8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(karar.etiket, style: const TextStyle(fontSize: 12.5)),
                );
              }).toList(),
            ),
          ],
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
