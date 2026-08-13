// Görsel dil: duyurular_ekrani.dart/is_ilanlari_ekrani.dart ile AYNI marka
// paleti. 11.08.2026'da (Berzan'ın isteğiyle) işletme SEÇME adımı kaldırıldı
// — bölgede kaç Cookzone işletmesi olursa olsun kullanıcı tek bir birleşik
// menü görür, "Ana Kafeterya" gibi bir isim öne çıkmaz. Backend hâlâ birden
// çok işletmeyi destekliyor (`GET /cookzone/isletmeler` liste döner), burada
// sadece İLK işletme kullanılıyor — ileride gerçekten çoklu işletme
// gerekirse bu varsayım gözden geçirilir.
//
// `cookzone_yetkilisi` bu ekrana hiç girmemeli (onlar için ayrı bir yönetim
// ekranı var, bkz. cookzone_isletme_siparisleri_ekrani.dart) — yönlendirme
// yonlendirici.dart'taki `redirect`te yapılıyor, burada tekrar kontrol
// etmiyoruz (tek sorumluluk: yönlendirme kararı router'ın işi).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/cookzone_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../../domain/cookzone_kurallari.dart';
import '../cookzone_gorseli.dart';
import '../durum/cookzone_isletmeler_durumu.dart';
import '../durum/sepet_notifier.dart';

class CookzoneEkrani extends ConsumerWidget {
  const CookzoneEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(cookzoneIsletmelerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: durum.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (hata, _) => _HataGorunumu(
            mesaj: '$hata',
            tekrarDene: () => ref.invalidate(cookzoneIsletmelerProvider),
          ),
          data: (isletmeler) {
            if (isletmeler.isEmpty) {
              return const _UstBaslik(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('Henüz Cookzone menüsü yok', style: TextStyle(color: Renkler.beyaz)),
                  ),
                ),
              );
            }
            return _MenuGorunumu(isletme: isletmeler.first);
          },
        ),
      ),
    );
  }
}

class _HataGorunumu extends StatelessWidget {
  const _HataGorunumu({required this.mesaj, required this.tekrarDene});

  final String mesaj;
  final VoidCallback tekrarDene;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40, color: Renkler.metinIkincil),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(mesaj, textAlign: TextAlign.center, style: const TextStyle(color: Renkler.metinIkincil)),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: tekrarDene, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}

class _MenuGorunumu extends ConsumerStatefulWidget {
  const _MenuGorunumu({required this.isletme});

  final CookzoneIsletmeResponse isletme;

  @override
  ConsumerState<_MenuGorunumu> createState() => _MenuGorunumuDurumu();
}

class _MenuGorunumuDurumu extends ConsumerState<_MenuGorunumu> {
  String? _seciliKategori;

  @override
  Widget build(BuildContext context) {
    final isletme = widget.isletme;
    final sepet = ref.watch(sepetNotifierProvider(isletme.id));
    final toplam = sepetToplami(sepet, isletme.menuOgeleri);
    final adet = sepet.values.fold(0, (toplam, adet) => toplam + adet);

    final kategoriler = <String>{for (final oge in isletme.menuOgeleri) oge.kategori}.toList();
    final gosterilecek = _seciliKategori == null
        ? isletme.menuOgeleri
        : isletme.menuOgeleri.where((oge) => oge.kategori == _seciliKategori).toList();

    return Column(
      children: [
        _UstBaslik(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Renkler.beyaz),
                  onPressed: () => context.go('/'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cookzone', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Renkler.beyaz)),
                      const SizedBox(height: 6),
                      Container(width: 28, height: 2, color: Renkler.altin),
                      const SizedBox(height: 6),
                      Text(
                        'Bölge içi yemek siparişi',
                        style: TextStyle(fontSize: 13, color: Renkler.beyaz.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _KategoriCipleri(
          kategoriler: kategoriler,
          secili: _seciliKategori,
          secildi: (kategori) => setState(() => _seciliKategori = kategori),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: gosterilecek.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final oge = gosterilecek[index];
              return _MenuOgesiKarti(oge: oge, adet: sepet[oge.id] ?? 0, isletmeId: isletme.id);
            },
          ),
        ),
        if (adet > 0)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () => context.push('/cookzone/sepet/${isletme.id}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Renkler.lacivert,
                  foregroundColor: Renkler.beyaz,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$adet ürün · $toplam ₺', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const Text('Sepete Git →', style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _UstBaslik extends StatelessWidget {
  const _UstBaslik({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Renkler.lacivert, Renkler.mavi]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: child,
    );
  }
}

class _KategoriCipleri extends StatelessWidget {
  const _KategoriCipleri({required this.kategoriler, required this.secili, required this.secildi});

  final List<String> kategoriler;
  final String? secili;
  final ValueChanged<String?> secildi;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _Cip(etiket: 'Tümü', secili: secili == null, onTap: () => secildi(null)),
          for (final kategori in kategoriler) ...[
            const SizedBox(width: 8),
            _Cip(etiket: kategori, secili: secili == kategori, onTap: () => secildi(kategori)),
          ],
        ],
      ),
    );
  }
}

class _Cip extends StatelessWidget {
  const _Cip({required this.etiket, required this.secili, required this.onTap});

  final String etiket;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gorsel = kategoriGorseli(etiket == 'Tümü' ? null : etiket);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: secili ? Renkler.lacivert : Renkler.beyaz,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: secili ? Renkler.lacivert : Renkler.kenarlik),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(etiket == 'Tümü' ? Icons.grid_view_rounded : gorsel.ikon, size: 15, color: secili ? Renkler.beyaz : gorsel.renk),
            const SizedBox(width: 6),
            Text(
              etiket,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: secili ? Renkler.beyaz : Renkler.lacivert),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuOgesiKarti extends ConsumerWidget {
  const _MenuOgesiKarti({required this.oge, required this.adet, required this.isletmeId});

  final CookzoneMenuOgesiResponse oge;
  final int adet;
  final String isletmeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(sepetNotifierProvider(isletmeId).notifier);
    final gorsel = kategoriGorseli(oge.kategori);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Renkler.lacivert.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: gorsel.renk.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(gorsel.ikon, color: gorsel.renk, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(oge.ad, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: Renkler.lacivert)),
                if (oge.aciklama != null) ...[
                  const SizedBox(height: 3),
                  Text(oge.aciklama!, style: const TextStyle(fontSize: 12, color: Renkler.metinIkincil)),
                ],
                const SizedBox(height: 6),
                Text('${oge.fiyat} ₺', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Renkler.mavi)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (adet == 0)
            _YuvarlakButon(ikon: Icons.add, onTap: () => notifier.ekle(oge.id))
          else
            Row(
              children: [
                _YuvarlakButon(ikon: Icons.remove, onTap: () => notifier.azalt(oge.id)),
                SizedBox(width: 26, child: Text('$adet', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
                _YuvarlakButon(ikon: Icons.add, onTap: () => notifier.ekle(oge.id)),
              ],
            ),
        ],
      ),
    );
  }
}

class _YuvarlakButon extends StatelessWidget {
  const _YuvarlakButon({required this.ikon, required this.onTap});

  final IconData ikon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: Renkler.mavi.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(ikon, size: 16, color: Renkler.mavi),
      ),
    );
  }
}
