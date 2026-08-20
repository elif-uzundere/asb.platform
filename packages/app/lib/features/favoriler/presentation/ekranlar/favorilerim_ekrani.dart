// "Favorilerim" — İkinci El/Firma/İş İlanı için 3 sekme. Kullanıcı
// favorilerse favorilerinde gözüksün diye.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/favori_modelleri.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/renkler.dart';
import '../../../firmalar/presentation/widgets/firma_karti.dart';
import '../durum/favorilerim_liste_durumu.dart';
import '../widgets/favori_kalp_butonu.dart';

class FavorilerimEkrani extends StatelessWidget {
  const FavorilerimEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F8FC),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/profil');
              }
            },
            icon: const Icon(Icons.arrow_back_rounded, color: Renkler.lacivert),
          ),
          title: const Text(
            'Favorilerim',
            style: TextStyle(color: Renkler.lacivert, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          bottom: const TabBar(
            labelColor: Renkler.lacivert,
            unselectedLabelColor: Renkler.metinIkincil,
            indicatorColor: Renkler.mavi,
            tabs: [
              Tab(text: 'İkinci El'),
              Tab(text: 'Firmalar'),
              Tab(text: 'İş İlanları'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _IkinciElSekmesi(),
            _FirmaSekmesi(),
            _IsIlaniSekmesi(),
          ],
        ),
      ),
    );
  }
}

class _BosGorunum extends StatelessWidget {
  const _BosGorunum({required this.mesaj});

  final String mesaj;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border_rounded, size: 40, color: Color(0xFF98A2B3)),
            const SizedBox(height: 12),
            Text(mesaj, textAlign: TextAlign.center, style: const TextStyle(color: Renkler.metinIkincil)),
          ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(mesaj, textAlign: TextAlign.center, style: const TextStyle(color: Renkler.metinIkincil)),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: tekrarDene, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}

class _IkinciElSekmesi extends ConsumerWidget {
  const _IkinciElSekmesi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(favoriIkinciElIlanlariProvider);
    final paraFormati = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    return durum.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (hata, _) => _HataGorunumu(
        mesaj: '$hata',
        tekrarDene: () => ref.invalidate(favoriIkinciElIlanlariProvider),
      ),
      data: (ilanlar) {
        if (ilanlar.isEmpty) return const _BosGorunum(mesaj: 'Henüz favoriye eklediğiniz ikinci el ilanı yok.');
        return RefreshIndicator(
          onRefresh: () => ref.refresh(favoriIkinciElIlanlariProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ilanlar.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ilan = ilanlar[index];
              return _KompaktKart(
                gorselUrl: ilan.gorselUrl,
                baslik: ilan.baslik,
                altBaslik: paraFormati.format(ilan.fiyat),
                tur: FavoriHedefTuru.ikinciEl,
                hedefId: ilan.id,
                onTap: () => context.push('/ikinci-el/${ilan.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

class _FirmaSekmesi extends ConsumerWidget {
  const _FirmaSekmesi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(favoriFirmalarProvider);

    return durum.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (hata, _) => _HataGorunumu(
        mesaj: '$hata',
        tekrarDene: () => ref.invalidate(favoriFirmalarProvider),
      ),
      data: (firmalar) {
        if (firmalar.isEmpty) return const _BosGorunum(mesaj: 'Henüz favoriye eklediğiniz firma yok.');
        return RefreshIndicator(
          onRefresh: () => ref.refresh(favoriFirmalarProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: firmalar.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final firma = firmalar[index];
              return FirmaKarti(
                firma: firma,
                tiklandi: () => context.push('/firmalar/${firma.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

class _IsIlaniSekmesi extends ConsumerWidget {
  const _IsIlaniSekmesi();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(favoriIsIlanlariProvider);

    return durum.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (hata, _) => _HataGorunumu(
        mesaj: '$hata',
        tekrarDene: () => ref.invalidate(favoriIsIlanlariProvider),
      ),
      data: (ilanlar) {
        if (ilanlar.isEmpty) return const _BosGorunum(mesaj: 'Henüz favoriye eklediğiniz iş ilanı yok.');
        return RefreshIndicator(
          onRefresh: () => ref.refresh(favoriIsIlanlariProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ilanlar.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final ilan = ilanlar[index];
              return _KompaktKart(
                gorselUrl: null,
                ikonYeriIkonu: Icons.work_outline_rounded,
                baslik: ilan.baslik,
                altBaslik: ilan.firmaAdi,
                tur: FavoriHedefTuru.isIlani,
                hedefId: ilan.id,
                onTap: () => context.push('/is-ilanlari/${ilan.id}'),
              );
            },
          ),
        );
      },
    );
  }
}

/// İkinci El/İş İlanı favori sekmelerinde kullanılan ortak kompakt kart —
/// görsel varsa küçük resim, yoksa (İş İlanı) ikon rozeti.
class _KompaktKart extends StatelessWidget {
  const _KompaktKart({
    required this.baslik,
    required this.altBaslik,
    required this.tur,
    required this.hedefId,
    required this.onTap,
    this.gorselUrl,
    this.ikonYeriIkonu = Icons.image_outlined,
  });

  final String? gorselUrl;
  final IconData ikonYeriIkonu;
  final String baslik;
  final String altBaslik;
  final FavoriHedefTuru tur;
  final String hedefId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAECF0)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: gorselUrl == null
                      ? Container(
                          color: const Color(0xFFEEF4FA),
                          child: Icon(ikonYeriIkonu, color: const Color(0xFF667085)),
                        )
                      : Image.network(
                          medyaAdresiCozumle(gorselUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, hata, stackTrace) => Container(
                            color: const Color(0xFFEEF4FA),
                            child: Icon(ikonYeriIkonu, color: const Color(0xFF667085)),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Renkler.lacivert),
                    ),
                    const SizedBox(height: 3),
                    Text(altBaslik, style: const TextStyle(fontSize: 12, color: Renkler.metinIkincil)),
                  ],
                ),
              ),
              FavoriKalpButonu(tur: tur, hedefId: hedefId, boyut: 20),
            ],
          ),
        ),
      ),
    );
  }
}
