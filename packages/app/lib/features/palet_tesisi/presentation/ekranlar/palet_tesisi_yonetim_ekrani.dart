// palet_tesisi_yetkilisi için ayrı yönetim ekranı — cookzone_yetkilisi'nin
// /cookzone/yonetim'i ile aynı desen (router redirect'i yonlendirici.dart'ta).
// Müşteri tarafındaki palet_tesisi_ekrani.dart'a hiç dokunulmadı, bu tamamen
// ayrı bir dosya (yetkilinin kodlara erişimi yok, bu App'in içinde çalışan
// bir ekran — "ayrı dosya" derken kastedilen muhtemelen buydu: kod erişimi
// değil, kullanıcı deneyimi olarak ayrı bir akış).

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../../domain/palet.dart';
import '../providers/palet_tesisi_provider.dart';
import '../providers/palet_yonetim_notifier.dart';

class PaletTesisiYonetimEkrani extends ConsumerWidget {
  const PaletTesisiYonetimEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paletlerAsync = ref.watch(tumPaletlerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF153773),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
        title: const Text(
          'Palet Çeşitleri Yönetimi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2F65C8),
        onPressed: () => _paletFormunuAc(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Palet'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tumPaletlerProvider.future),
        child: paletlerAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (hata, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text('$hata', textAlign: TextAlign.center),
              ),
            ],
          ),
          data: (paletler) {
            if (paletler.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('Henüz palet çeşidi eklenmedi.')),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: paletler.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final palet = paletler[index];
                return _PaletYonetimKarti(
                  palet: palet,
                  tiklandi: () => _paletFormunuAc(context, duzenlenecekPalet: palet),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _paletFormunuAc(BuildContext context, {Palet? duzenlenecekPalet}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _PaletFormu(mevcutPalet: duzenlenecekPalet),
    );
  }
}

class _PaletYonetimKarti extends StatelessWidget {
  const _PaletYonetimKarti({required this.palet, required this.tiklandi});

  final Palet palet;
  final VoidCallback tiklandi;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: tiklandi,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE7E9EE)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: palet.gorselUrl == null
                      ? Container(
                          color: const Color(0xFFF0F2F5),
                          child: const Icon(Icons.image_outlined, color: Color(0xFF98A2B3)),
                        )
                      : Image.network(
                          medyaAdresiCozumle(palet.gorselUrl!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, hata, stackTrace) => Container(
                            color: const Color(0xFFF0F2F5),
                            child: const Icon(Icons.image_outlined, color: Color(0xFF98A2B3)),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      palet.ad,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF153773)),
                    ),
                    if (palet.olcu != null) ...[
                      const SizedBox(height: 3),
                      Text(palet.olcu!, style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: (palet.aktif ? const Color(0xFF16A34A) : const Color(0xFF667085)).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  palet.aktif ? 'Aktif' : 'Pasif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: palet.aktif ? const Color(0xFF16A34A) : const Color(0xFF667085),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Color(0xFF98A2B3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletFormu extends ConsumerStatefulWidget {
  const _PaletFormu({this.mevcutPalet});

  /// null ise "yeni palet ekle", doluysa "düzenle" (görsel dahil mevcut
  /// alanları güncelleme) modunda çalışır.
  final Palet? mevcutPalet;

  @override
  ConsumerState<_PaletFormu> createState() => _PaletFormuDurumu();
}

class _PaletFormuDurumu extends ConsumerState<_PaletFormu> {
  late final _ad = TextEditingController(text: widget.mevcutPalet?.ad ?? '');
  late final _aciklama = TextEditingController(text: widget.mevcutPalet?.aciklama ?? '');
  late final _olcu = TextEditingController(text: widget.mevcutPalet?.olcu ?? '');

  PlatformFile? _seciliGorsel;

  static const _izinliUzantilar = ['jpg', 'jpeg', 'png', 'webp'];
  static const _maksimumBoyutBayt = 5 * 1024 * 1024;

  @override
  void dispose() {
    _ad.dispose();
    _aciklama.dispose();
    _olcu.dispose();
    super.dispose();
  }

  Future<void> _gorselSec() async {
    final sonuc = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _izinliUzantilar,
      withData: true,
    );
    final dosya = sonuc?.files.singleOrNull;
    if (dosya == null) {
      return;
    }

    // "Uygun format ve boyutlarda tek yükleme" — backend de aynı sınırları
    // ayrıca uyguluyor (ParseFilePipe), ama burada erken uyarmak kullanıcıyı
    // gereksiz bir ağ isteğinden kurtarıyor.
    if (dosya.size > _maksimumBoyutBayt) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Görsel en fazla 5 MB olabilir.'), behavior: SnackBarBehavior.floating),
        );
      return;
    }

    final uzanti = dosya.extension?.toLowerCase();
    if (uzanti == null || !_izinliUzantilar.contains(uzanti)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Sadece JPG, PNG veya WEBP formatında görsel yükleyebilirsiniz.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    setState(() => _seciliGorsel = dosya);
  }

  void _gonder() {
    final duzenlemeModu = widget.mevcutPalet != null;
    final gorselBaytlari = _seciliGorsel?.bytes;
    final gorselDosyaAdi = _seciliGorsel?.name;

    if (duzenlemeModu) {
      ref.read(paletGuncelleNotifierProvider.notifier).guncelle(
            widget.mevcutPalet!.id,
            ad: _ad.text.trim(),
            aciklama: _aciklama.text.trim(),
            olcu: _olcu.text.trim(),
            gorselBaytlari: gorselBaytlari,
            gorselDosyaAdi: gorselDosyaAdi,
          );
    } else {
      ref.read(paletOlusturNotifierProvider.notifier).olustur(
            ad: _ad.text.trim(),
            aciklama: _aciklama.text.trim(),
            olcu: _olcu.text.trim(),
            gorselBaytlari: gorselBaytlari,
            gorselDosyaAdi: gorselDosyaAdi,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final duzenlemeModu = widget.mevcutPalet != null;
    final notifierProvider = duzenlemeModu ? paletGuncelleNotifierProvider : paletOlusturNotifierProvider;

    ref.listen<IslemDurumu>(notifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: duzenlemeModu ? 'Palet güncellenemedi' : 'Palet oluşturulamadı',
        basariBasligi: duzenlemeModu ? 'Palet güncellendi' : 'Palet eklendi',
        basariSonrasi: () => Navigator.of(context).pop(),
        sifirla: duzenlemeModu
            ? ref.read(paletGuncelleNotifierProvider.notifier).sifirla
            : ref.read(paletOlusturNotifierProvider.notifier).sifirla,
      );
    });

    final yukleniyor = ref.watch(notifierProvider) is IslemSuruyor;
    final mevcutGorselUrl = widget.mevcutPalet?.gorselUrl;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            duzenlemeModu ? 'Paleti Düzenle' : 'Yeni Palet Çeşidi',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF153773)),
          ),
          const SizedBox(height: 16),
          GirdiKutusu(denetleyici: _ad, ipucu: 'Palet adı', ikon: Icons.view_module_outlined),
          const SizedBox(height: 14),
          GirdiKutusu(denetleyici: _aciklama, ipucu: 'Açıklama (opsiyonel)', ikon: Icons.notes_rounded),
          const SizedBox(height: 14),
          GirdiKutusu(denetleyici: _olcu, ipucu: 'Ölçü, örn. 120x80 cm (opsiyonel)', ikon: Icons.straighten_outlined),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: yukleniyor ? null : _gorselSec,
            icon: const Icon(Icons.image_outlined, size: 18),
            label: Text(
              _seciliGorsel != null
                  ? _seciliGorsel!.name
                  : mevcutGorselUrl != null
                      ? 'Görseli Değiştir'
                      : 'Görsel Ekle (opsiyonel, JPG/PNG/WEBP, max 5 MB)',
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(46),
              foregroundColor: const Color(0xFF153773),
              side: const BorderSide(color: Color(0xFFE7E9EE)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 18),
          BirincilButon(
            yazi: yukleniyor ? 'Kaydediliyor...' : 'Kaydet',
            yukleniyor: yukleniyor,
            basildi: _gonder,
          ),
        ],
      ),
    );
  }
}
