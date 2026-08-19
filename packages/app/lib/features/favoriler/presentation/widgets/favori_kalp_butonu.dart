// İkinci El/Firma/İş İlanı kartlarında/detaylarında kullanılan ortak "kalp"
// butonu — üç yerde de aynı görünüm/davranış (18.08.2026, Berzan'ın isteği).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/favori_modelleri.dart';
import '../../../auth/presentation/durum/auth_durumu.dart';
import '../durum/favori_durumu.dart';

class FavoriKalpButonu extends ConsumerWidget {
  const FavoriKalpButonu({
    super.key,
    required this.tur,
    required this.hedefId,
    this.boyut = 22,
    this.doluRenk = const Color(0xFFE0245E),
    this.bosRenk = const Color(0xFF98A2B3),
  });

  final FavoriHedefTuru tur;
  final String hedefId;
  final double boyut;
  final Color doluRenk;
  final Color bosRenk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final girisYapildi = ref.watch(authProvider).girisYapildi;
    final favoride = ref.watch(favorideMiProvider((tur: tur, hedefId: hedefId)));
    final degisiyor = ref.watch(favoriToggleNotifierProvider);

    return InkWell(
      onTap: degisiyor
          ? null
          : () {
              if (!girisYapildi) {
                context.push('/giris');
                return;
              }
              ref.read(favoriToggleNotifierProvider.notifier).degistir(tur, hedefId);
            },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          favoride ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: boyut,
          color: favoride ? doluRenk : bosRenk,
        ),
      ),
    );
  }
}
