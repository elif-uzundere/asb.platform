// Duyuru + öne çıkan İkinci El ilanlarını tek bir listeye birleştirir.
// İki kaynak da FutureProvider — Riverpod `ref.watch` ile ikisini bekleyip
// birleştiriyoruz, biri hata verirse diğerini de kaybetmemek için ayrı
// AsyncValue olarak değil, ikisi de hazır olunca birleşik liste üretiyoruz.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../duyurular/presentation/durum/duyuru_durumu.dart';
import '../../../ikinci_el/domain/ikinci_el_ilan.dart';
import '../../../ikinci_el/presentation/providers/ikinci_el_provider.dart';
import '../../domain/one_cikan_ogesi.dart';

const int _gosterilecekAdet = 4;

String _fiyatFormatla(double fiyat) {
  final tamKisim = fiyat.truncate().toString();
  final gruplu = StringBuffer();
  for (var i = 0; i < tamKisim.length; i++) {
    if (i > 0 && (tamKisim.length - i) % 3 == 0) gruplu.write('.');
    gruplu.write(tamKisim[i]);
  }
  return '$gruplu ₺';
}

String _tarihiFormatla(DateTime tarih) {
  String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
  return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year}';
}

final oneCikanlarProvider = FutureProvider.autoDispose<List<OneCikanOgesi>>((ref) async {
  final duyurular = await ref.watch(duyuruListesiProvider.future);
  // İkinci El herkese açık bir katalog değil, hata durumunda (örn. henüz
  // giriş yapmamış ziyaretçi) Öne Çıkanlar'ın tamamen boş görünmesine sebep
  // olmasın diye ayrı yakalanıyor — duyurular yine gösterilir.
  final ikinciElIlanlar = await ref
      .watch(ikinciElIlanlariProvider.future)
      .catchError((_) => const <IkinciElIlan>[]);

  final ogeler = <OneCikanOgesi>[
    for (final duyuru in duyurular)
      OneCikanOgesi(
        tur: OneCikanTuru.duyuru,
        baslik: duyuru.baslik,
        altBaslik: _tarihiFormatla(duyuru.yayinTarihi),
        tarih: duyuru.yayinTarihi,
        kategori: duyuru.kategori,
        hedefId: duyuru.id,
      ),
    for (final ilan in ikinciElIlanlar)
      if (ilan.oneCikan)
        OneCikanOgesi(
          tur: OneCikanTuru.ikinciEl,
          baslik: ilan.baslik,
          altBaslik: _fiyatFormatla(ilan.fiyat),
          tarih: ilan.olusturulmaTarihi,
          hedefId: ilan.id,
        ),
  ];

  ogeler.sort((a, b) => b.tarih.compareTo(a.tarih));
  return ogeler.take(_gosterilecekAdet).toList();
});
