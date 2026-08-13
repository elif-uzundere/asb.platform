// Görsel dil: firma_detay_ekrani.dart ile AYNI desen (hero + üstüne taşan
// beyaz raf, aynı radius/translate tekniği — bkz. oradaki not).
//
// Aksiyon alanı role'e göre değişir: ilan sahibi firma yetkilisi
// "Başvurular"/"İlanı Kapat" görür, diğerleri (uygunsa) "Başvur" görür.
// Kararlar domain/is_ilani_kurallari.dart'ta — widget sadece sonucu çizer.

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/is_ilani_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../../../auth/presentation/durum/auth_durumu.dart';
import '../../domain/is_ilani_kurallari.dart';
import '../durum/is_ilani_basvuru_notifier.dart';
import '../durum/is_ilani_detay_durumu.dart';
import '../durum/is_ilani_kapat_notifier.dart';

class IsIlaniDetayEkrani extends ConsumerWidget {
  const IsIlaniDetayEkrani({super.key, required this.ilanId});

  final String ilanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detay = ref.watch(isIlaniDetayProvider(ilanId));

    return detay.when(
      loading: () => const _BasitIskelet(),
      error: (hata, _) => _BasitHata(mesaj: '$hata'),
      data: (ilan) => _IlanDetaySayfasi(ilan: ilan),
    );
  }
}

class _BasitIskelet extends StatelessWidget {
  const _BasitIskelet();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Renkler.beyaz, foregroundColor: Renkler.lacivert, elevation: 0),
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
      appBar: AppBar(backgroundColor: Renkler.beyaz, foregroundColor: Renkler.lacivert, elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(mesaj, textAlign: TextAlign.center, style: const TextStyle(color: Renkler.metinIkincil)),
        ),
      ),
    );
  }
}

class _IlanDetaySayfasi extends ConsumerWidget {
  const _IlanDetaySayfasi({required this.ilan});

  final IsIlaniResponse ilan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kullanici = ref.watch(authProvider).kullanici;
    final girisYapildi = ref.watch(authProvider).girisYapildi;
    final sahibiMi = ilanSahibiMi(ilan, kullanici);

    ref.listen<IslemDurumu>(isIlaniBasvuruNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Başvuru gönderilemedi',
        basariBasligi: 'Başvurunuz alındı',
        basariMesaji: 'Firma yetkilisi başvurunuzu inceleyecek.',
        sifirla: ref.read(isIlaniBasvuruNotifierProvider.notifier).sifirla,
      );
    });

    ref.listen<IslemDurumu>(isIlaniKapatNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'İlan kapatılamadı',
        basariBasligi: 'İlan kapatıldı',
        basariMesaji: 'Bu ilan artık yeni başvuru kabul etmiyor.',
        sifirla: ref.read(isIlaniKapatNotifierProvider.notifier).sifirla,
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Renkler.lacivert,
            foregroundColor: Renkler.beyaz,
            elevation: 0,
            expandedHeight: 210,
            flexibleSpace: FlexibleSpaceBar(background: _HeroArkaPlani(ilan: ilan)),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24),
                decoration: const BoxDecoration(
                  color: Renkler.beyaz,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    _AciklamaKarti(ilan: ilan),
                    const SizedBox(height: 20),
                    _AksiyonAlani(
                      ilan: ilan,
                      sahibiMi: sahibiMi,
                      girisYapildi: girisYapildi,
                      basvuruYapilabilir: basvuruYapilabilirMi(ilan, kullanici),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroArkaPlani extends StatelessWidget {
  const _HeroArkaPlani({required this.ilan});

  final IsIlaniResponse ilan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Renkler.lacivert, Renkler.mavi]),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 32, left: 32, right: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ilan.baslik,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Renkler.beyaz),
              ),
              const SizedBox(height: 8),
              Text(
                ilan.firmaAdi,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Renkler.beyaz.withValues(alpha: 0.85)),
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
                  durumEtiketi(ilan.durum),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Renkler.beyaz),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AciklamaKarti extends StatelessWidget {
  const _AciklamaKarti({required this.ilan});

  final IsIlaniResponse ilan;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Renkler.kenarlik),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ilan.konum != null) ...[
            _BilgiSatiri(ikon: Icons.location_on_outlined, baslik: 'Konum', deger: ilan.konum!),
            const SizedBox(height: 14),
          ],
          _BilgiSatiri(ikon: Icons.calendar_today_outlined, baslik: 'Yayın Tarihi', deger: tarihiFormatla(ilan.yayinTarihi)),
          const SizedBox(height: 18),
          const Text(
            'AÇIKLAMA',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Renkler.metinIkincil, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Text(ilan.aciklama, style: const TextStyle(fontSize: 14, color: Renkler.lacivert, height: 1.5)),
        ],
      ),
    );
  }
}

class _BilgiSatiri extends StatelessWidget {
  const _BilgiSatiri({required this.ikon, required this.baslik, required this.deger});

  final IconData ikon;
  final String baslik;
  final String deger;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
          child: Icon(ikon, size: 16, color: Renkler.metinIkincil),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(baslik, style: const TextStyle(fontSize: 12, color: Renkler.metinIkincil)),
              const SizedBox(height: 2),
              Text(deger, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AksiyonAlani extends ConsumerStatefulWidget {
  const _AksiyonAlani({
    required this.ilan,
    required this.sahibiMi,
    required this.girisYapildi,
    required this.basvuruYapilabilir,
  });

  final IsIlaniResponse ilan;
  final bool sahibiMi;
  final bool girisYapildi;
  final bool basvuruYapilabilir;

  @override
  ConsumerState<_AksiyonAlani> createState() => _AksiyonAlaniDurumu();
}

class _AksiyonAlaniDurumu extends ConsumerState<_AksiyonAlani> {
  PlatformFile? _seciliCv;

  Future<void> _cvSec() async {
    final sonuc = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true,
    );
    final dosya = sonuc?.files.singleOrNull;
    if (dosya == null) {
      return;
    }
    setState(() => _seciliCv = dosya);
  }

  @override
  Widget build(BuildContext context) {
    final ilan = widget.ilan;
    final sahibiMi = widget.sahibiMi;
    final girisYapildi = widget.girisYapildi;
    final basvuruYapilabilir = widget.basvuruYapilabilir;

    if (sahibiMi) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            BirincilButon(
              yazi: 'Başvuruları Gör',
              basildi: () => context.push('/is-ilanlari/${ilan.id}/basvurular'),
            ),
            if (ilan.durum == IsIlaniDurumu.aktif) ...[
              const SizedBox(height: 10),
              _KapatButonu(ilanId: ilan.id),
            ],
          ],
        ),
      );
    }

    if (!girisYapildi) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BirincilButon(yazi: 'Başvurmak için giriş yap', basildi: () => context.push('/giris')),
      );
    }

    if (!basvuruYapilabilir) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _BilgiSeridi(
          mesaj: ilan.durum == IsIlaniDurumu.kapali
              ? 'Bu ilan artık başvuruya kapalı.'
              : 'Bu ilana başvuramazsınız.',
        ),
      );
    }

    final yukleniyor = ref.watch(isIlaniBasvuruNotifierProvider) is IslemSuruyor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          OutlinedButton.icon(
            onPressed: yukleniyor ? null : _cvSec,
            icon: const Icon(Icons.attach_file_rounded, size: 18),
            label: Text(
              _seciliCv == null ? 'CV Ekle (opsiyonel)' : _seciliCv!.name,
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              foregroundColor: Renkler.lacivert,
              side: const BorderSide(color: Renkler.kenarlik),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          BirincilButon(
            yazi: yukleniyor ? 'Gönderiliyor...' : 'Başvur',
            yukleniyor: yukleniyor,
            basildi: () => ref.read(isIlaniBasvuruNotifierProvider.notifier).basvur(
                  ilan.id,
                  cvBaytlari: _seciliCv?.bytes,
                  cvDosyaAdi: _seciliCv?.name,
                ),
          ),
        ],
      ),
    );
  }
}

class _KapatButonu extends ConsumerWidget {
  const _KapatButonu({required this.ilanId});

  final String ilanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yukleniyor = ref.watch(isIlaniKapatNotifierProvider) is IslemSuruyor;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: yukleniyor ? null : () => _onaySor(context, ref),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: const BorderSide(color: Color(0xFFDC2626)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(yukleniyor ? 'Kapatılıyor...' : 'İlanı Kapat'),
      ),
    );
  }

  Future<void> _onaySor(BuildContext context, WidgetRef ref) async {
    final onaylandi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı kapat'),
        content: const Text('Bu ilan kapatıldıktan sonra yeni başvuru alınamaz. Emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kapat', style: TextStyle(color: Color(0xFFDC2626))),
          ),
        ],
      ),
    );
    if (onaylandi == true) {
      await ref.read(isIlaniKapatNotifierProvider.notifier).kapat(ilanId);
    }
  }
}

class _BilgiSeridi extends StatelessWidget {
  const _BilgiSeridi({required this.mesaj});

  final String mesaj;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFEEF5FC), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Renkler.mavi, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(mesaj, style: const TextStyle(fontSize: 12.5, color: Renkler.lacivert))),
        ],
      ),
    );
  }
}
