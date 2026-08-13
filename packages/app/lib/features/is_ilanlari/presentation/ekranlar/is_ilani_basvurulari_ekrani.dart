// Sadece ilan sahibi firma yetkilisi buraya gelebiliyor (detay ekranındaki
// buton is_ilani_kurallari.dart → ilanSahibiMi() ile gizleniyor; backend da
// 403 ile ayrıca koruyor). Onayla/Reddet/İncele aksiyonları burada.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/is_ilani_modelleri.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../../domain/is_ilani_kurallari.dart';
import '../durum/is_basvurusu_durum_guncelle_notifier.dart';
import '../durum/is_ilani_basvurulari_durumu.dart';

class IsIlaniBasvurulariEkrani extends ConsumerWidget {
  const IsIlaniBasvurulariEkrani({super.key, required this.ilanId});

  final String ilanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(isIlaniBasvurulariProvider(ilanId));

    ref.listen<IslemDurumu>(isBasvurusuDurumGuncelleNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Başvuru güncellenemedi',
        sifirla: ref.read(isBasvurusuDurumGuncelleNotifierProvider.notifier).sifirla,
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Başvurular'),
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
        data: (basvurular) {
          if (basvurular.isEmpty) {
            return const Center(
              child: Text('Henüz başvuru yok', style: TextStyle(color: Renkler.metinIkincil)),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: basvurular.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _BasvuruKarti(ilanId: ilanId, basvuru: basvurular[index]),
          );
        },
      ),
    );
  }
}

class _BasvuruKarti extends ConsumerWidget {
  const _BasvuruKarti({required this.ilanId, required this.basvuru});

  final String ilanId;
  final IsBasvurusuResponse basvuru;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yukleniyor = ref.watch(isBasvurusuDurumGuncelleNotifierProvider) is IslemSuruyor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Renkler.kenarlik),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: Renkler.mavi.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.person_outline_rounded, color: Renkler.mavi, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      basvuru.kullaniciAdSoyad,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Renkler.lacivert),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tarihiFormatla(basvuru.basvuruTarihi),
                      style: const TextStyle(fontSize: 12, color: Renkler.metinIkincil),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _durumRengi(basvuru.durum).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  basvuruDurumuEtiketi(basvuru.durum),
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _durumRengi(basvuru.durum)),
                ),
              ),
            ],
          ),
          if (basvuru.cvUrl != null) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () => launchUrl(Uri.parse(medyaAdresi(basvuru.cvUrl!)), mode: LaunchMode.externalApplication),
              child: const Row(
                children: [
                  Icon(Icons.attach_file_rounded, size: 16, color: Renkler.mavi),
                  SizedBox(width: 4),
                  Text('CV\'yi Görüntüle', style: TextStyle(fontSize: 12.5, color: Renkler.mavi, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: basvuruIcinUygunKararlar(basvuru.durum).map((karar) {
              return OutlinedButton(
                onPressed: yukleniyor
                    ? null
                    : () => ref
                        .read(isBasvurusuDurumGuncelleNotifierProvider.notifier)
                        .guncelle(ilanId, basvuru.id, karar),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kararRengi(karar),
                  side: BorderSide(color: _kararRengi(karar)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(basvuruKarariEtiketi(karar), style: const TextStyle(fontSize: 12.5)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _durumRengi(IsBasvurusuDurumu durum) => switch (durum) {
        IsBasvurusuDurumu.beklemede => Renkler.altin,
        IsBasvurusuDurumu.incelendi => Renkler.mavi,
        IsBasvurusuDurumu.reddedildi => const Color(0xFFDC2626),
        IsBasvurusuDurumu.kabul => const Color(0xFF16A34A),
      };

  Color _kararRengi(IsBasvurusuKarari karar) => switch (karar) {
        IsBasvurusuKarari.incelendi => Renkler.mavi,
        IsBasvurusuKarari.reddedildi => const Color(0xFFDC2626),
        IsBasvurusuKarari.kabul => const Color(0xFF16A34A),
      };
}
