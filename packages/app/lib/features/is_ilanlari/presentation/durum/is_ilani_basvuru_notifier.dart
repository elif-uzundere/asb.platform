import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../data/is_ilani_api.dart';

class IsIlaniBasvuruNotifier extends FormNotifier {
  IsIlaniBasvuruNotifier(this._ref);

  final Ref _ref;

  Future<void> basvur(String ilanId, {Uint8List? cvBaytlari, String? cvDosyaAdi}) {
    return calistir(
      () => _ref.read(isIlaniApiProvider).basvur(
            ilanId,
            cvBaytlari: cvBaytlari,
            cvDosyaAdi: cvDosyaAdi,
          ),
    );
  }
}

final isIlaniBasvuruNotifierProvider =
    StateNotifierProvider.autoDispose<IsIlaniBasvuruNotifier, IslemDurumu>(
  IsIlaniBasvuruNotifier.new,
);
