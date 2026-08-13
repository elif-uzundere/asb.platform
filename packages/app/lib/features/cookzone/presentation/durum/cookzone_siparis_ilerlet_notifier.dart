import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../data/cookzone_api.dart';
import 'cookzone_isletme_siparisleri_durumu.dart';

class CookzoneSiparisIlerletNotifier extends FormNotifier {
  CookzoneSiparisIlerletNotifier(this._ref);

  final Ref _ref;

  Future<void> ilerlet(String siparisId) {
    return calistir(() async {
      await _ref.read(cookzoneApiProvider).siparisIlerlet(siparisId);
      _ref.invalidate(cookzoneIsletmeSiparisleriProvider);
    });
  }
}

final cookzoneSiparisIlerletNotifierProvider =
    StateNotifierProvider.autoDispose<CookzoneSiparisIlerletNotifier, IslemDurumu>(
  CookzoneSiparisIlerletNotifier.new,
);
