// Derin link için GET /duyurular/{id} kullanır (listeden taşınan nesneyle
// değil) — bkz. firma_detay_ekrani.dart başındaki aynı gerekçe / docs/CLAUDE.md
// derin link kararı.
//
// Görsel dil: firma_detay_ekrani.dart ile AYNI hero + taşan beyaz raf deseni
// (lacivert→mavi degrade, Transform.translate(-28), radius 28) — sadece
// avatar yerine kategoriye göre ikon dairesi var, "kişi/firma" değil "içerik"
// gösterildiği için.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/duyuru_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../duyuru_gorseli.dart';
import '../durum/duyuru_durumu.dart';

class DuyuruDetayEkrani extends ConsumerWidget {
  const DuyuruDetayEkrani({super.key, required this.duyuruId});

  final String duyuruId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durum = ref.watch(duyuruDetayProvider(duyuruId));

    return durum.when(
      loading: () => const _BasitIskelet(),
      error: (hata, _) => _BasitHata(mesaj: '$hata'),
      data: (duyuru) => _DuyuruDetaySayfasi(duyuru: duyuru),
    );
  }
}

class _BasitIskelet extends StatelessWidget {
  const _BasitIskelet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Renkler.beyaz,
        foregroundColor: Renkler.lacivert,
        elevation: 0,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _BasitHata extends StatelessWidget {
  const _BasitHata({required this.mesaj});

  final String mesaj;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Renkler.beyaz,
        foregroundColor: Renkler.lacivert,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            mesaj,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Renkler.metinIkincil),
          ),
        ),
      ),
    );
  }
}

class _DuyuruDetaySayfasi extends StatelessWidget {
  const _DuyuruDetaySayfasi({required this.duyuru});

  final DuyuruResponse duyuru;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Renkler.lacivert,
            foregroundColor: Renkler.beyaz,
            elevation: 0,
            expandedHeight: 244,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroArkaPlani(duyuru: duyuru),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Column(
                children: [
                  _IcerikRafi(duyuru: duyuru),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroArkaPlani extends StatelessWidget {
  const _HeroArkaPlani({required this.duyuru});

  final DuyuruResponse duyuru;

  @override
  Widget build(BuildContext context) {
    final gorsel = kategoriGorseli(duyuru.kategori);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Renkler.lacivert, Renkler.mavi],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Renkler.beyaz,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: gorsel.renk.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(gorsel.ikon, color: gorsel.renk, size: 30),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  duyuru.baslik,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Renkler.beyaz,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(width: 28, height: 2, color: Renkler.altin),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Renkler.beyaz.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Renkler.beyaz.withValues(alpha: 0.3)),
                ),
                child: Text(
                  duyuru.kategori ?? 'Genel',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Renkler.beyaz,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero'nun altına kesintisiz devam eden, TAM GENİŞLİKTE beyaz raf — firma
/// detayındaki hızlı aksiyonlar rafıyla aynı teknik, ama burada eylem
/// butonları yerine doğrudan duyuru metni var.
class _IcerikRafi extends StatelessWidget {
  const _IcerikRafi({required this.duyuru});

  final DuyuruResponse duyuru;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 0),
      decoration: const BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Renkler.metinIkincil,
                ),
                const SizedBox(width: 6),
                Text(
                  _tarihiFormatla(duyuru.yayinTarihi),
                  style: const TextStyle(fontSize: 12, color: Renkler.metinIkincil),
                ),
                const SizedBox(width: 12),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_outlined, size: 16, color: Renkler.metinIkincil),
                  tooltip: 'Metni kopyala',
                  onPressed: () => _icerigiKopyala(context, duyuru),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Divider(color: Renkler.kenarlik, height: 24),
            Text(
              duyuru.icerik,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _icerigiKopyala(BuildContext context, DuyuruResponse duyuru) {
    Clipboard.setData(ClipboardData(text: '${duyuru.baslik}\n\n${duyuru.icerik}'));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Duyuru metni kopyalandı')));
  }
}

String _tarihiFormatla(DateTime tarih) {
  String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
  return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year}';
}
