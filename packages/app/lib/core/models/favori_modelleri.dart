// Kaynak: packages/shared-types/src/favori.types.ts
// Manuel mirror — bkz. auth_modelleri.dart başındaki not.

/// TS: `type FavoriHedefTuru`
enum FavoriHedefTuru {
  ikinciEl('ikinci_el'),
  firma('firma'),
  isIlani('is_ilani');

  const FavoriHedefTuru(this.deger);

  final String deger;
}
