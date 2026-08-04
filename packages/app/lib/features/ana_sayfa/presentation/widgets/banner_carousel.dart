// Kaynak (carousel mekaniği + ölçüler):
// Kaynak: eski Expo src/features/ana-sayfa/components/banner.tsx (silindi — bkz. izlence Ek A)
//
// Mekanik birebir taşındı: yatay sayfalanan görünüm (RN'de pagingEnabled
// ScrollView → Flutter'da PageView), 2 saniyelik otomatik kaydırma Timer'ı,
// alt nokta göstergesi.
//
// FARK: Eski sürüm 3 sabit metin banner'ıydı ve backend'e bağlı değildi.
// Bu sürüm gerçekten GET /banners'tan besleniyor; `gorselUrl` network image
// olarak gösteriliyor, `linkUrl` doluysa banner tıklanabilir oluyor.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/banner_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../../data/banner_api.dart';
import '../../data/banner_baglanti_servisi.dart';
import '../../domain/banner_kurallari.dart';

/// Ana Sayfa artık header'sız — banner tam genişlikte, sayfanın en üstünde
/// ASB'nin kendi web sitesindeki gibi bir "hero" görseli olarak duruyor
/// (bkz. kullanıcının paylaştığı ekran görüntüsü).
const double _bannerYuksekligi = 200;
const double _bannerKosesi = 24;

/// banner.tsx: dot #cccccc 8x8, aktif nokta #0A4D8C ve 20 genişlik.
const Color _noktaRengi = Color(0xFFCCCCCC);
const Color _aktifNoktaRengi = Color(0xFF0A4D8C);

class BannerCarousel extends ConsumerWidget {
  const BannerCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannerlar = ref.watch(bannerlarProvider);

    return bannerlar.when(
      loading: () => const _BannerKabi(
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (hata, _) => _BannerKabi(
        child: Center(
          child: Text(
            '$hata',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Renkler.metinIkincil),
          ),
        ),
      ),
      data: (liste) {
  if (liste.isEmpty) {
    return const _BannerKabi(
      child: SizedBox(),
    );
  }

  return _BannerKaydirici(bannerlar: liste);
},
    );
  }
}

/// Tam genişlik, sadece alt köşeleri yuvarlak — sayfanın en üstünde header
/// yerine geçen bir hero banner.
class _BannerKabi extends StatelessWidget {
  const _BannerKabi({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(_bannerKosesi),
        bottomRight: Radius.circular(_bannerKosesi),
      ),
      child: SizedBox(
        width: double.infinity,
        height: _bannerYuksekligi,
        child: ColoredBox(color: Renkler.beyaz, child: child),
      ),
    );
  }
}

class _BannerKaydirici extends ConsumerStatefulWidget {
  const _BannerKaydirici({required this.bannerlar});

  final List<BannerResponse> bannerlar;

  @override
  ConsumerState<_BannerKaydirici> createState() => _BannerKaydiriciDurumu();
}

class _BannerKaydiriciDurumu extends ConsumerState<_BannerKaydirici> {
  final _denetleyici = PageController();
  Timer? _zamanlayici;
  int _aktifBanner = 0;

  @override
  void initState() {
    super.initState();
    _zamanlayiciyiBaslat();
  }

  @override
  void didUpdateWidget(covariant _BannerKaydirici eski) {
    super.didUpdateWidget(eski);
    if (eski.bannerlar.length != widget.bannerlar.length) {
      _aktifBanner = 0;
      _zamanlayiciyiBaslat();
    }
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    _denetleyici.dispose();
    super.dispose();
  }

  void _zamanlayiciyiBaslat() {
    _zamanlayici?.cancel();
    // Tek banner varsa kaydıracak bir şey yok.
    if (widget.bannerlar.length < 2) return;

    _zamanlayici = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!_denetleyici.hasClients) return;
      final sonraki = (_aktifBanner + 1) % widget.bannerlar.length;
      _denetleyici.animateToPage(
        sonraki,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _bannerAc(BannerResponse banner) async {
    // Adresin geçerliliği ve açılması servis/domain katmanında.
    final acildi = await ref.read(bannerBaglantiServisiProvider).bannerAc(banner);
    if (!acildi && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Bağlantı açılamadı.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _BannerKabi(
      child: Stack(
        children: [
          PageView.builder(
            controller: _denetleyici,
            itemCount: widget.bannerlar.length,
            onPageChanged: (indeks) => setState(() => _aktifBanner = indeks),
            itemBuilder: (context, indeks) {
              final banner = widget.bannerlar[indeks];
              return GestureDetector(
                onTap: banner.tiklanabilir ? () => _bannerAc(banner) : null,
                child: MouseRegion(
                  cursor: banner.tiklanabilir
                      ? SystemMouseCursors.click
                      : MouseCursor.defer,
                  child: Image.network(
                    banner.gorselUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: _bannerYuksekligi,
                    errorBuilder: (context, hata, iz) => const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Renkler.metinIkincil,
                      ),
                    ),
                    loadingBuilder: (context, cocuk, ilerleme) =>
                        ilerleme == null
                            ? cocuk
                            : const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.bannerlar.length; i++)
                  Container(
                    width: i == _aktifBanner ? 20 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: i == _aktifBanner ? _aktifNoktaRengi : _noktaRengi,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
