// US-003 kabul kriteri: "Öne Çıkanlar bölümü en güncel 4 duyuru/haberi
// tarih + başlık ile listeler". 18.08.2026'da Berzan'ın isteğiyle genişledi:
// admin panelinden "öne çıkan" işaretlenmiş İkinci El ilanları da bu listeye
// karışıyor (bkz. one_cikanlar_durumu.dart — birleştirme orada yapılıyor,
// bu widget sadece gösterim).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';
import '../../../duyurular/presentation/duyuru_gorseli.dart';
import '../../domain/one_cikan_ogesi.dart';
import '../durum/one_cikanlar_durumu.dart';

class OneCikanlarBolumu extends ConsumerWidget {
  const OneCikanlarBolumu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oneCikanlar = ref.watch(oneCikanlarProvider);

    return oneCikanlar.when(
      loading: () => const _Yukleniyor(),
      error: (hata, _) => const SizedBox.shrink(),
      data: (liste) {
        if (liste.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final oge in liste) ...[
              _OneCikanKarti(oge: oge),
            ],
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => context.go('/duyurular'),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tümünü Gör', style: TextStyle(fontSize: 12.5, color: Renkler.mavi)),
                      Icon(Icons.chevron_right_rounded, size: 18, color: Renkler.mavi),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OneCikanKarti extends StatelessWidget {
  const _OneCikanKarti({required this.oge});

  final OneCikanOgesi oge;

  @override
  Widget build(BuildContext context) {
    final gorsel = oge.tur == OneCikanTuru.ikinciEl
        ? (ikon: Icons.shopping_bag_outlined, renk: Renkler.lacivert)
        : kategoriGorseli(oge.kategori);

    return InkWell(
      onTap: () {
        if (oge.tur == OneCikanTuru.duyuru) {
          context.push('/duyurular/${oge.hedefId}');
        } else {
          context.push('/ikinci-el/${oge.hedefId}');
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Renkler.beyaz,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: gorsel.renk.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(gorsel.ikon, color: gorsel.renk, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    oge.baslik,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Renkler.lacivert,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    oge.altBaslik,
                    style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Renkler.metinIkincil, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Yukleniyor extends StatelessWidget {
  const _Yukleniyor();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
