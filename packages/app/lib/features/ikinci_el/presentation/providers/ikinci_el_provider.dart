import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/ikinci_el_api.dart';
import '../../domain/ikinci_el_ilan.dart';

/// Backend'den gerçek ikinci el ilanlarını getirir.
///
/// GET /ikinci-el-pazar
final ikinciElIlanlariProvider =
    FutureProvider<List<IkinciElIlan>>((ref) async {
  final api = ref.watch(ikinciElApiProvider);

  return api.ilanlariGetir();
});

/// Tek bir ilanın detayı — ayrı bir `GET /ikinci-el-pazar/:id` ucu yok,
/// zaten çekilmiş listeden id'ye göre bulunuyor (liste herkese açık ve
/// ekranlar arası paylaşılıyor, ekstra ağ isteğine gerek yok).
final ikinciElIlanDetayProvider =
    Provider.family<IkinciElIlan?, String>((ref, id) {
  final ilanlarAsync = ref.watch(ikinciElIlanlariProvider);
  return ilanlarAsync.whenOrNull(
    data: (ilanlar) => ilanlar.where((ilan) => ilan.id == id).firstOrNull,
  );
});
