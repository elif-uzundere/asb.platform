// Firmalar listesi ekranının state'i: arama metni + seçili sektör + o anki
// filtreye göre çekilen firma listesi.
//
// Neden FutureProvider değil de elle bir Notifier: arama VE sektör filtresi
// birlikte değişebiliyor, ikisi tek bir "sorgu" state'i olarak tutulmalı ki
// her ikisi de aynı isteğe girsin. Ayrıca arama debounce'unu (300ms) burada
// yönetiyoruz — widget'ın Timer tutması demek widget'ta iş mantığı demek
// olurdu (mimari kural 10).

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/firma_modelleri.dart';
import '../../../../core/network/api_hata.dart';
import '../../data/firma_api.dart';
import '../../domain/firma_kurallari.dart';

const _aramaGecikmesi = Duration(milliseconds: 300);

sealed class FirmaListeDurumu {
  const FirmaListeDurumu();
}

class FirmaListeYukleniyor extends FirmaListeDurumu {
  const FirmaListeYukleniyor();
}

class FirmaListeHazir extends FirmaListeDurumu {
  const FirmaListeHazir(this.firmalar);
  final List<FirmaResponse> firmalar;
}

class FirmaListeHatali extends FirmaListeDurumu {
  const FirmaListeHatali(this.mesaj);
  final String mesaj;
}

class FirmaListeNotifier extends StateNotifier<FirmaListeDurumu> {
  FirmaListeNotifier(this._api) : super(const FirmaListeYukleniyor()) {
    _yenidenYukle();
  }

  final FirmaApi _api;
  Timer? _debounce;
  String _arama = '';
  String? _sektor;

  String get aramaMetni => _arama;
  String? get seciliSektor => _sektor;

  /// Her tuş vuruşunda çağrılır ama istek hemen atılmaz — kullanıcı yazmayı
  /// bitirene kadar (300ms sessizlik) bekler. Sunucu tarafı arama seçildiği
  /// için (bkz. teknikPlan.md ?search= sözleşmesi) bu olmadan her tuşta
  /// ağ isteği gider.
  void aramaDegisti(String yeniMetin) {
    _arama = yeniMetin;
    _debounce?.cancel();
    _debounce = Timer(_aramaGecikmesi, _yenidenYukle);
  }

  /// Sektör çipleri anlık tepki verir — kullanıcı zaten net bir seçim yaptı,
  /// debounce'a gerek yok.
  void sektorSecildi(String? sektor) {
    _sektor = sektor;
    _debounce?.cancel();
    _yenidenYukle();
  }

  void filtreleriTemizle() {
    _arama = '';
    _sektor = null;
    _yenidenYukle();
  }

  /// Dışarıdan (RouteAware.didPopNext gibi) tetiklenen yenileme. Mevcut
  /// arama/sektör filtresini KORUR — kullanıcı bir firmanın detayına gidip
  /// geri döndüğünde filtresi sıfırlanmamalı, sadece veri tazelenmeli.
  Future<void> disaridanYenile() => _yenidenYukle();

  Future<void> _yenidenYukle() async {
    state = const FirmaListeYukleniyor();
    try {
      final firmalar = await _api.listele(
        FirmaSorgusu(arama: _arama, sektor: _sektor),
      );
      if (mounted) state = FirmaListeHazir(firmalar);
    } on ApiHata catch (hata) {
      if (mounted) state = FirmaListeHatali(hata.mesaj);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final firmaListeNotifierProvider =
    StateNotifierProvider.autoDispose<FirmaListeNotifier, FirmaListeDurumu>(
  (ref) => FirmaListeNotifier(ref.watch(firmaApiProvider)),
);

/// Sektör çiplerini besler. Ayrı bir provider olmasının sebebi: liste
/// filtrelendikçe yeniden çekilmemeli — sektör çipleri sabit kalmalı, yoksa
/// kullanıcı "Tekstil" filtresine bastığında diğer çipler kaybolurdu.
final sektorlerProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.watch(firmaApiProvider).sektorler(),
);
