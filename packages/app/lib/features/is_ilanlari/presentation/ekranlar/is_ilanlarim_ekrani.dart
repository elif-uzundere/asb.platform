// Profil → İş İlanlarım (firma_yetkilisi görünümü). Karta tıklayınca mevcut
// is_ilani_detay_ekrani.dart'a gidiyor — orası zaten sahip için "Başvuruları
// Gör"/"İlanı Kapat" gösteriyor (ilanSahibiMi), burada tekrar yazmaya gerek yok.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/is_ilani_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../../domain/is_ilani_kurallari.dart';
import '../durum/is_ilanlarim_durumu.dart';

class IsIlanlarimEkrani extends ConsumerWidget {
  const IsIlanlarimEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(isIlanlarimProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _UstBaslik(adet: durum.valueOrNull?.length),
            Expanded(
              child: durum.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (hata, _) => _HataGorunumu(
                  mesaj: '$hata',
                  tekrarDene: () => ref.invalidate(isIlanlarimProvider),
                ),
                data: (ilanlar) {
                  if (ilanlar.isEmpty) return const _BosGorunum();
                  return RefreshIndicator(
                    onRefresh: () => ref.refresh(isIlanlarimProvider.future),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      children: [
                        for (final ilan in ilanlar) ...[
                          _IlanKarti(
                            ilan: ilan,
                            tiklandi: () => context.push('/is-ilanlari/${ilan.id}'),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UstBaslik extends StatelessWidget {
  const _UstBaslik({required this.adet});

  final int? adet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Renkler.lacivert, Renkler.mavi],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Renkler.beyaz),
              onPressed: () => context.go('/'),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İş İlanlarım',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Renkler.beyaz),
                    ),
                    const SizedBox(height: 6),
                    Container(width: 28, height: 2, color: Renkler.altin),
                    const SizedBox(height: 6),
                    Text(
                      adet == null ? 'Yükleniyor...' : '$adet ilan',
                      style: TextStyle(fontSize: 13, color: Renkler.beyaz.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IlanKarti extends StatelessWidget {
  const _IlanKarti({required this.ilan, required this.tiklandi});

  final IsIlaniResponse ilan;
  final VoidCallback tiklandi;

  @override
  Widget build(BuildContext context) {
    final aktifMi = ilan.durum == IsIlaniDurumu.aktif;
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
                      ilan.baslik,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Renkler.lacivert),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: Renkler.metinIkincil),
                        const SizedBox(width: 4),
                        Text(tarihiFormatla(ilan.yayinTarihi), style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil)),
                        const SizedBox(width: 10),
                        const Icon(Icons.favorite_border_rounded, size: 12, color: Renkler.metinIkincil),
                        const SizedBox(width: 3),
                        Text('${ilan.favoriSayisi}', style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil)),
                        const SizedBox(width: 10),
                        const Icon(Icons.bookmark_border_rounded, size: 12, color: Renkler.metinIkincil),
                        const SizedBox(width: 3),
                        Text('${ilan.basvuruSayisi} başvuru', style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (aktifMi ? const Color(0xFF16A34A) : Renkler.metinIkincil).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  durumEtiketi(ilan.durum),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: aktifMi ? const Color(0xFF16A34A) : Renkler.metinIkincil,
                  ),
                ),
              ),
            ],
          ),
        ),
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
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: Renkler.mavi.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.work_outline_rounded, size: 30, color: Renkler.mavi),
          ),
          const SizedBox(height: 14),
          const Text(
            'Henüz ilan açmadınız',
            textAlign: TextAlign.center,
            style: TextStyle(color: Renkler.metinIkincil, fontWeight: FontWeight.w500),
          ),
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
            child: Text(mesaj, textAlign: TextAlign.center, style: const TextStyle(color: Renkler.metinIkincil)),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: tekrarDene, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}
