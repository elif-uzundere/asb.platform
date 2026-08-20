// Sepet artık modal bottom sheet değil, ayrı bir tam sayfa. Daha modern
// olsun ve kendi sayfası olsun diye. Sepet hâlâ sepet_notifier.dart'taki
// saf yerel state, backend'e sadece "Siparişi Onayla"ya basınca gidiliyor.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/cookzone_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../../domain/cookzone_kurallari.dart';
import '../cookzone_gorseli.dart';
import '../durum/cookzone_isletmeler_durumu.dart';
import '../durum/cookzone_siparis_olustur_notifier.dart';
import '../durum/sepet_notifier.dart';

class CookzoneSepetEkrani extends ConsumerWidget {
  const CookzoneSepetEkrani({super.key, required this.isletmeId});

  final String isletmeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detay = ref.watch(cookzoneIsletmeDetayProvider(isletmeId));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Sepetim'),
        backgroundColor: Renkler.beyaz,
        foregroundColor: Renkler.lacivert,
        elevation: 0,
      ),
      body: detay.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('$hata', textAlign: TextAlign.center, style: const TextStyle(color: Renkler.metinIkincil)),
          ),
        ),
        data: (isletme) => _SepetIcerigi(isletme: isletme),
      ),
    );
  }
}

class _SepetIcerigi extends ConsumerStatefulWidget {
  const _SepetIcerigi({required this.isletme});

  final CookzoneIsletmeResponse isletme;

  @override
  ConsumerState<_SepetIcerigi> createState() => _SepetIcerigiDurumu();
}

class _SepetIcerigiDurumu extends ConsumerState<_SepetIcerigi> {
  DateTime? _alinmaSaati;

  Future<void> _saatSec() async {
    final simdi = DateTime.now();
    final tarih = await showDatePicker(
      context: context,
      initialDate: simdi,
      firstDate: simdi,
      lastDate: simdi.add(const Duration(days: 14)),
    );
    if (tarih == null || !mounted) return;

    final saat = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(simdi));
    if (saat == null) return;

    setState(() {
      _alinmaSaati = DateTime(tarih.year, tarih.month, tarih.day, saat.hour, saat.minute);
    });
  }

  void _gonder() {
    final alinmaSaati = _alinmaSaati;
    if (alinmaSaati == null) return;
    final sepet = ref.read(sepetNotifierProvider(widget.isletme.id));
    ref.read(cookzoneSiparisOlusturNotifierProvider.notifier).gonder(
          isletmeId: widget.isletme.id,
          alinmaSaati: alinmaSaati,
          sepet: sepet,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<IslemDurumu>(cookzoneSiparisOlusturNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Sipariş oluşturulamadı',
        basariBasligi: 'Siparişiniz alındı',
        basariMesaji: 'İşletme siparişinizi onayladığında bilgilendirileceksiniz.',
        basariSonrasi: () {
          Navigator.of(context).pop();
        },
        sifirla: ref.read(cookzoneSiparisOlusturNotifierProvider.notifier).sifirla,
      );
    });

    final sepet = ref.watch(sepetNotifierProvider(widget.isletme.id));
    final notifier = ref.read(sepetNotifierProvider(widget.isletme.id).notifier);
    final ogeHaritasi = {for (final oge in widget.isletme.menuOgeleri) oge.id: oge};
    final toplam = sepetToplami(sepet, widget.isletme.menuOgeleri);
    final yukleniyor = ref.watch(cookzoneSiparisOlusturNotifierProvider) is IslemSuruyor;
    final alinmaSaatiGecerli = _alinmaSaati != null && alinmaSaatiGecerliMi(_alinmaSaati!);

    if (sepet.isEmpty) {
      return const Center(
        child: Text('Sepetiniz boş', style: TextStyle(color: Renkler.metinIkincil)),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sepet.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final girdi = sepet.entries.elementAt(index);
              final oge = ogeHaritasi[girdi.key];
              if (oge == null) return const SizedBox.shrink();
              return _SepetSatiri(oge: oge, adet: girdi.value, notifier: notifier);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Renkler.beyaz,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Renkler.lacivert.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Toplam', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Renkler.lacivert)),
                  Text('$toplam ₺', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Renkler.mavi)),
                ],
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _saatSec,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(border: Border.all(color: Renkler.kenarlik), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 18, color: Renkler.metinIkincil),
                      const SizedBox(width: 10),
                      Text(
                        _alinmaSaati == null ? 'Alınma saati seçin' : tarihSaatiFormatla(_alinmaSaati!),
                        style: const TextStyle(fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BirincilButon(
                yazi: yukleniyor ? 'Gönderiliyor...' : 'Siparişi Onayla',
                yukleniyor: yukleniyor || !alinmaSaatiGecerli,
                basildi: _gonder,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SepetSatiri extends StatelessWidget {
  const _SepetSatiri({required this.oge, required this.adet, required this.notifier});

  final CookzoneMenuOgesiResponse oge;
  final int adet;
  final SepetNotifier notifier;

  @override
  Widget build(BuildContext context) {
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
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: gorsel.renk.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(gorsel.ikon, color: gorsel.renk, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(oge.ad, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Renkler.lacivert)),
                const SizedBox(height: 3),
                Text('${oge.fiyat} ₺ · ${oge.fiyat * adet} ₺ toplam', style: const TextStyle(fontSize: 11.5, color: Renkler.metinIkincil)),
              ],
            ),
          ),
          _YuvarlakButon(ikon: Icons.remove, onTap: () => notifier.azalt(oge.id)),
          SizedBox(width: 26, child: Text('$adet', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700))),
          _YuvarlakButon(ikon: Icons.add, onTap: () => notifier.ekle(oge.id)),
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: Renkler.mavi.withValues(alpha: 0.1), shape: BoxShape.circle),
        child: Icon(ikon, size: 15, color: Renkler.mavi),
      ),
    );
  }
}
