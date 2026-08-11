import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/acil_durum_api.dart';
import '../../domain/acil_durum_birimi.dart';
import '../../domain/toplanma_alani.dart';

final acilDurumBirimleriProvider =
    FutureProvider<List<AcilDurumBirimi>>(
  (ref) async {
    final api =
        ref.watch(acilDurumApiProvider);

    final gelenBilgiler =
        await api.bilgileriGetir();

    final bilgiHaritasi = {
      for (final bilgi in gelenBilgiler)
        bilgi.tur.trim().toLowerCase():
            bilgi,
    };

    return AcilDurumBirimi.sabitTurler
        .map(
          (tur) {
            final anahtar =
                tur.trim().toLowerCase();

            return bilgiHaritasi[anahtar] ??
                AcilDurumBirimi.bos(
                  tur,
                );
          },
        )
        .toList();
  },
);

final acilDurumBirimiDetayProvider =
    FutureProvider.family<
        AcilDurumBirimi,
        String>(
  (ref, tur) async {
    final api =
        ref.watch(acilDurumApiProvider);

    final bilgiler =
        await api.bilgileriGetir();

    final arananTur =
        tur.trim().toLowerCase();

    for (final bilgi in bilgiler) {
      if (bilgi.tur
              .trim()
              .toLowerCase() ==
          arananTur) {
        return bilgi;
      }
    }

    return AcilDurumBirimi.bos(
      tur,
    );
  },
);

final toplanmaAlanlariProvider =
    FutureProvider<List<ToplanmaAlani>>(
  (ref) async {
    final api =
        ref.watch(acilDurumApiProvider);

    return api
        .toplanmaAlanlariniGetir();
  },
);