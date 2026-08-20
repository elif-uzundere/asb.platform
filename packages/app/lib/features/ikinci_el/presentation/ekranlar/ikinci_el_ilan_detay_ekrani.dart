// İlan kartına dokununca açılan gerçek detay ekranı. Daha önce sadece
// "detay sayfası daha sonra bağlanacak" mesajı veriyordu. İletişim telefonu
// artık zorunlu bir alan, bir yerde gösterilmezse anlamsız kalırdı.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/models/favori_modelleri.dart';
import '../../../../core/network/api_client.dart';
import '../../../favoriler/presentation/widgets/favori_kalp_butonu.dart';
import '../../domain/ikinci_el_ilan.dart';
import '../providers/ikinci_el_provider.dart';

class IkinciElIlanDetayEkrani extends ConsumerWidget {
  const IkinciElIlanDetayEkrani({super.key, required this.ilanId});

  final String ilanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ilan = ref.watch(ikinciElIlanDetayProvider(ilanId));

    return Scaffold(
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
              context.go('/ikinci-el');
            }
          },
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0B315E)),
        ),
        title: const Text(
          'İlan Detayı',
          style: TextStyle(color: Color(0xFF0B315E), fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: ilan == null ? const _BulunamadiIcerigi() : _DetayIcerigi(ilan: ilan),
    );
  }
}

class _BulunamadiIcerigi extends StatelessWidget {
  const _BulunamadiIcerigi();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'İlan bulunamadı — kaldırılmış ya da satılmış olabilir.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF667085), fontSize: 14),
        ),
      ),
    );
  }
}

class _DetayIcerigi extends StatefulWidget {
  const _DetayIcerigi({required this.ilan});

  final IkinciElIlan ilan;

  @override
  State<_DetayIcerigi> createState() => _DetayIcerigiDurumu();
}

class _DetayIcerigiDurumu extends State<_DetayIcerigi> {
  final _sayfaDenetleyici = PageController();
  int _seciliFotoIndeksi = 0;

  @override
  void dispose() {
    _sayfaDenetleyici.dispose();
    super.dispose();
  }

  Future<void> _telefonuAra(String telefon) async {
    final acildi = await launchUrl(Uri(scheme: 'tel', path: telefon));
    if (!acildi && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Telefon uygulaması açılamadı.'), behavior: SnackBarBehavior.floating),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ilan = widget.ilan;
    final fotograflar = ilan.fotografUrls.isNotEmpty ? ilan.fotografUrls : [ilan.gorselUrl];
    final paraFormati = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
      children: [
        _FotografGalerisi(
          fotograflar: fotograflar,
          denetleyici: _sayfaDenetleyici,
          seciliIndeks: _seciliFotoIndeksi,
          degisti: (index) => setState(() => _seciliFotoIndeksi = index),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ilan.baslik,
                      style: const TextStyle(color: Color(0xFF0B315E), fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  FavoriKalpButonu(tur: FavoriHedefTuru.ikinciEl, hedefId: ilan.id, boyut: 26),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                paraFormati.format(ilan.fiyat),
                style: const TextStyle(color: Color(0xFF0B5EA8), fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Etiket(metin: ilan.kategori, ikon: Icons.category_outlined),
                  _Etiket(metin: ilan.durum, ikon: Icons.inventory_2_outlined),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Açıklama',
                style: TextStyle(color: Color(0xFF0B315E), fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                ilan.aciklama,
                style: const TextStyle(color: Color(0xFF344054), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEAECF0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 18, color: Color(0xFF667085)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ilan.firmaAdi,
                            style: const TextStyle(color: Color(0xFF344054), fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () => _telefonuAra(ilan.iletisimTelefonu),
                        icon: const Icon(Icons.phone_rounded, size: 18),
                        label: Text('Ara — ${ilan.iletisimTelefonu}'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0B5EA8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FotografGalerisi extends StatelessWidget {
  const _FotografGalerisi({
    required this.fotograflar,
    required this.denetleyici,
    required this.seciliIndeks,
    required this.degisti,
  });

  final List<String> fotograflar;
  final PageController denetleyici;
  final int seciliIndeks;
  final void Function(int index) degisti;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: denetleyici,
            onPageChanged: degisti,
            itemCount: fotograflar.length,
            itemBuilder: (context, index) => Image.network(
              medyaAdresiCozumle(fotograflar[index]),
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFEEF4FA),
                child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF667085), size: 40),
              ),
            ),
          ),
        ),
        if (fotograflar.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < fotograflar.length; i++)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == seciliIndeks ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Etiket extends StatelessWidget {
  const _Etiket({required this.metin, required this.ikon});

  final String metin;
  final IconData ikon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0B5EA8).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 14, color: const Color(0xFF0B5EA8)),
          const SizedBox(width: 5),
          Text(metin, style: const TextStyle(color: Color(0xFF0B5EA8), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
