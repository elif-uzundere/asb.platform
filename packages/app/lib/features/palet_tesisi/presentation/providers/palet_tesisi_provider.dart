import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/palet_tesisi_api.dart';
import '../../domain/palet.dart';
import '../../domain/palet_tesisi_bilgisi.dart';

final paletTesisiBilgisiProvider =
    FutureProvider<PaletTesisiBilgisi?>(
  (ref) async {
    final api =
        ref.watch(paletTesisiApiProvider);

    return api.tesisBilgisiGetir();
  },
);

final paletlerProvider =
    FutureProvider<List<Palet>>(
  (ref) async {
    final api =
        ref.watch(paletTesisiApiProvider);

    return api.paletleriGetir();
  },
);

/// Palet Tesisi yönetim ekranı — pasif olanlar dahil hepsi.
final tumPaletlerProvider =
    FutureProvider<List<Palet>>(
  (ref) async {
    final api =
        ref.watch(paletTesisiApiProvider);

    return api.tumPaletleriGetir();
  },
);