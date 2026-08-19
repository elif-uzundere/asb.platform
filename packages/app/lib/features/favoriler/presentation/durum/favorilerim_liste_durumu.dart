// Favorilerim ekranının 3 sekmesi için: hangi ilan/firma id'lerinin
// favorilendiğini `favorilerimProvider`den alıp, o türün zaten var olan tam
// listesiyle (ikinciElIlanlariProvider/firmaApiProvider/isIlaniApiProvider)
// eşleştiriyor. Ayrı bir "favori detaylarım" backend ucu yok — favori
// tablosu sadece id tutuyor (bkz. packages/backend/src/modules/favori), asıl
// veri her zaman kendi modülünden gelir.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/favori_modelleri.dart';
import '../../../../core/models/firma_modelleri.dart';
import '../../../../core/models/is_ilani_modelleri.dart';
import '../../../firmalar/data/firma_api.dart';
import '../../../firmalar/domain/firma_kurallari.dart';
import '../../../ikinci_el/domain/ikinci_el_ilan.dart';
import '../../../ikinci_el/presentation/providers/ikinci_el_provider.dart';
import '../../../is_ilanlari/data/is_ilani_api.dart';
import 'favori_durumu.dart';

final favoriIkinciElIlanlariProvider = FutureProvider.autoDispose<List<IkinciElIlan>>((ref) async {
  final favoriIdleri = await ref.watch(favorilerimProvider(FavoriHedefTuru.ikinciEl).future);
  if (favoriIdleri.isEmpty) return const [];
  final ilanlar = await ref.watch(ikinciElIlanlariProvider.future);
  return ilanlar.where((ilan) => favoriIdleri.contains(ilan.id)).toList();
});

final favoriFirmalarProvider = FutureProvider.autoDispose<List<FirmaResponse>>((ref) async {
  final favoriIdleri = await ref.watch(favorilerimProvider(FavoriHedefTuru.firma).future);
  if (favoriIdleri.isEmpty) return const [];
  final firmalar = await ref.watch(firmaApiProvider).listele(const FirmaSorgusu());
  return firmalar.where((firma) => favoriIdleri.contains(firma.id)).toList();
});

final favoriIsIlanlariProvider = FutureProvider.autoDispose<List<IsIlaniResponse>>((ref) async {
  final favoriIdleri = await ref.watch(favorilerimProvider(FavoriHedefTuru.isIlani).future);
  if (favoriIdleri.isEmpty) return const [];
  final ilanlar = await ref.watch(isIlaniApiProvider).listele();
  return ilanlar.where((ilan) => favoriIdleri.contains(ilan.id)).toList();
});
