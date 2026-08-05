// US-003 kabul kriteri: "Öne Çıkanlar bölümü en güncel 4 duyuru/haberi
// tarih + başlık ile listeler". Önceki hâli tek bir statik "Duyurular"
// nav kartıydı — artık duyuruListesiProvider'dan gerçek veri çekiyor
// (backend zaten yayinTarihi'ne göre azalan sırayla döndürüyor).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';
import '../../../duyurular/presentation/duyuru_gorseli.dart';
import '../../../duyurular/presentation/durum/duyuru_durumu.dart';

const int _gosterilecekAdet = 4;

class OneCikanlarBolumu extends ConsumerWidget {
  const OneCikanlarBolumu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duyurular = ref.watch(duyuruListesiProvider);

    return duyurular.when(
      loading: () => const _Yukleniyor(),
      error: (hata, _) => const SizedBox.shrink(),
      data: (liste) {
        if (liste.isEmpty) return const SizedBox.shrink();
        final ilkDort = liste.take(_gosterilecekAdet).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final duyuru in ilkDort) ...[
              InkWell(
                onTap: () => context.push('/duyurular/${duyuru.id}'),
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
                          color: kategoriGorseli(duyuru.kategori).renk.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          kategoriGorseli(duyuru.kategori).ikon,
                          color: kategoriGorseli(duyuru.kategori).renk,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              duyuru.baslik,
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
                              _tarihiFormatla(duyuru.yayinTarihi),
                              style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Renkler.metinIkincil, size: 20),
                    ],
                  ),
                ),
              ),
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

String _tarihiFormatla(DateTime tarih) {
  String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
  return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year}';
}
