import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/destek_talebi_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../durum/destek_talebi_durumu.dart';

class TaleplerimEkrani extends ConsumerWidget {
  const TaleplerimEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final talepler = ref.watch(taleplerimProvider);

    return Scaffold(
      backgroundColor: Renkler.beyaz,
      appBar: AppBar(
        title: const Text('Taleplerim'),
        backgroundColor: Renkler.beyaz,
        foregroundColor: Renkler.lacivert,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(taleplerimProvider.future),
        child: talepler.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (hata, _) => _Mesaj(metin: '$hata'),
          data: (liste) => liste.isEmpty
              ? const _Mesaj(metin: 'Henüz bir destek talebiniz yok.')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: liste.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, indeks) => _TalepKarti(talep: liste[indeks]),
                ),
        ),
      ),
    );
  }
}

class _Mesaj extends StatelessWidget {
  const _Mesaj({required this.metin});

  final String metin;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, kisitlar) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: kisitlar.maxHeight),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                metin,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Renkler.metinIkincil),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TalepKarti extends StatelessWidget {
  const _TalepKarti({required this.talep});

  final DestekTalebiResponse talep;

  Color get _durumRengi => switch (talep.durum) {
        DestekTalebiDurumu.beklemede => Renkler.altin,
        DestekTalebiDurumu.yanitlandi => const Color(0xFF16A34A),
        DestekTalebiDurumu.kapali => Renkler.metinIkincil,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  talep.baslik,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Renkler.lacivert,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _durumRengi.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  talep.durum.gorunenAd,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _durumRengi),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            talep.aciklama,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Renkler.metinIkincil, height: 1.4),
          ),
          const SizedBox(height: 8),
          Text(
            _tarihiFormatla(talep.olusturmaTarihi),
            style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil),
          ),
        ],
      ),
    );
  }
}

String _tarihiFormatla(DateTime tarih) {
  String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
  return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year} '
      '${ikiHane(tarih.hour)}:${ikiHane(tarih.minute)}';
}
