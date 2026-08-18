// cookzone_yetkilisi'nin kendi işletmesinin menüsünü yönettiği ekran —
// Palet Tesisi'ndeki palet_tesisi_yonetim_ekrani.dart ile aynı desen
// (bottom sheet form + kart listesi + gerçek görsel yükleme).

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/cookzone_modelleri.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../durum/cookzone_menu_yonetim_durumu.dart';

class CookzoneMenuYonetimEkrani extends ConsumerWidget {
  const CookzoneMenuYonetimEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(cookzoneMenuYonetimProvider);

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
              context.go('/cookzone/yonetim');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        ),
        title: const Text(
          'Menü Yönetimi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2F65C8),
        onPressed: () => _menuFormunuAc(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Ürün'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(cookzoneMenuYonetimProvider.future),
        child: menuAsync.when(
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
          data: (menuOgeleri) {
            if (menuOgeleri.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: Text('Henüz menü öğesi eklenmedi.')),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: menuOgeleri.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final oge = menuOgeleri[index];
                return _MenuOgesiKarti(
                  oge: oge,
                  tiklandi: () => _menuFormunuAc(context, duzenlenecekOge: oge),
                  silTiklandi: () => _silmeyiOnayla(context, ref, oge),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _menuFormunuAc(BuildContext context, {CookzoneMenuOgesiResponse? duzenlenecekOge}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _MenuOgesiFormu(mevcutOge: duzenlenecekOge),
    );
  }

  Future<void> _silmeyiOnayla(BuildContext context, WidgetRef ref, CookzoneMenuOgesiResponse oge) async {
    final onaylandi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü kaldır'),
        content: Text('"${oge.ad}" menüden kaldırılsın mı? (Geçmiş siparişler etkilenmez.)'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Kaldır', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (onaylandi != true) return;
    if (!context.mounted) return;
    await ref.read(cookzoneMenuOgesiSilNotifierProvider.notifier).sil(oge.id);
  }
}

class _MenuOgesiKarti extends StatelessWidget {
  const _MenuOgesiKarti({required this.oge, required this.tiklandi, required this.silTiklandi});

  final CookzoneMenuOgesiResponse oge;
  final VoidCallback tiklandi;
  final VoidCallback silTiklandi;

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
                  child: oge.gorselUrl == null
                      ? Container(
                          color: const Color(0xFFF0F2F5),
                          child: const Icon(Icons.image_outlined, color: Color(0xFF98A2B3)),
                        )
                      : Image.network(
                          medyaAdresiCozumle(oge.gorselUrl!),
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
                      oge.ad,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF153773)),
                    ),
                    const SizedBox(height: 3),
                    Text('${oge.fiyat} ₺ · ${oge.kategori}', style: const TextStyle(fontSize: 12, color: Color(0xFF667085))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: (oge.aktif ? const Color(0xFF16A34A) : const Color(0xFF667085)).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  oge.aktif ? 'Aktif' : 'Pasif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: oge.aktif ? const Color(0xFF16A34A) : const Color(0xFF667085),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: silTiklandi,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, color: Color(0xFFD92D20), size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuOgesiFormu extends ConsumerStatefulWidget {
  const _MenuOgesiFormu({this.mevcutOge});

  /// null ise "yeni ürün ekle", doluysa "düzenle" modunda çalışır.
  final CookzoneMenuOgesiResponse? mevcutOge;

  @override
  ConsumerState<_MenuOgesiFormu> createState() => _MenuOgesiFormuDurumu();
}

class _MenuOgesiFormuDurumu extends ConsumerState<_MenuOgesiFormu> {
  late final _ad = TextEditingController(text: widget.mevcutOge?.ad ?? '');
  late final _aciklama = TextEditingController(text: widget.mevcutOge?.aciklama ?? '');
  late final _fiyat = TextEditingController(text: widget.mevcutOge?.fiyat.toString() ?? '');
  late final _kategori = TextEditingController(text: widget.mevcutOge?.kategori ?? '');

  PlatformFile? _seciliGorsel;

  static const _izinliUzantilar = ['jpg', 'jpeg', 'png', 'webp'];
  static const _maksimumBoyutBayt = 5 * 1024 * 1024;

  @override
  void dispose() {
    _ad.dispose();
    _aciklama.dispose();
    _fiyat.dispose();
    _kategori.dispose();
    super.dispose();
  }

  Future<void> _gorselSec() async {
    final sonuc = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _izinliUzantilar,
      withData: true,
    );
    final dosya = sonuc?.files.singleOrNull;
    if (dosya == null) return;

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
    final duzenlemeModu = widget.mevcutOge != null;
    final fiyat = num.tryParse(_fiyat.text.trim().replaceAll(',', '.'));
    if (fiyat == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Geçerli bir fiyat yazmalısınız.'), behavior: SnackBarBehavior.floating),
        );
      return;
    }

    final gorselBaytlari = _seciliGorsel?.bytes;
    final gorselDosyaAdi = _seciliGorsel?.name;

    if (duzenlemeModu) {
      ref.read(cookzoneMenuOgesiGuncelleNotifierProvider.notifier).guncelle(
            widget.mevcutOge!.id,
            ad: _ad.text.trim(),
            aciklama: _aciklama.text.trim(),
            fiyat: fiyat,
            kategori: _kategori.text.trim(),
            gorselBaytlari: gorselBaytlari,
            gorselDosyaAdi: gorselDosyaAdi,
          );
    } else {
      ref.read(cookzoneMenuOgesiOlusturNotifierProvider.notifier).olustur(
            ad: _ad.text.trim(),
            aciklama: _aciklama.text.trim(),
            fiyat: fiyat,
            kategori: _kategori.text.trim(),
            gorselBaytlari: gorselBaytlari,
            gorselDosyaAdi: gorselDosyaAdi,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final duzenlemeModu = widget.mevcutOge != null;
    final notifierProvider =
        duzenlemeModu ? cookzoneMenuOgesiGuncelleNotifierProvider : cookzoneMenuOgesiOlusturNotifierProvider;

    ref.listen<IslemDurumu>(notifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: duzenlemeModu ? 'Ürün güncellenemedi' : 'Ürün eklenemedi',
        basariBasligi: duzenlemeModu ? 'Ürün güncellendi' : 'Ürün eklendi',
        basariSonrasi: () => Navigator.of(context).pop(),
        sifirla: duzenlemeModu
            ? ref.read(cookzoneMenuOgesiGuncelleNotifierProvider.notifier).sifirla
            : ref.read(cookzoneMenuOgesiOlusturNotifierProvider.notifier).sifirla,
      );
    });

    final yukleniyor = ref.watch(notifierProvider) is IslemSuruyor;
    final mevcutGorselUrl = widget.mevcutOge?.gorselUrl;

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
            duzenlemeModu ? 'Ürünü Düzenle' : 'Yeni Menü Ürünü',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF153773)),
          ),
          const SizedBox(height: 16),
          GirdiKutusu(denetleyici: _ad, ipucu: 'Ürün adı', ikon: Icons.restaurant_menu_outlined),
          const SizedBox(height: 14),
          GirdiKutusu(denetleyici: _aciklama, ipucu: 'Açıklama (opsiyonel)', ikon: Icons.notes_rounded),
          const SizedBox(height: 14),
          GirdiKutusu(
            denetleyici: _fiyat,
            ipucu: 'Fiyat (₺)',
            ikon: Icons.payments_outlined,
            klavyeTipi: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 14),
          GirdiKutusu(denetleyici: _kategori, ipucu: 'Kategori, örn. Ana Yemek', ikon: Icons.category_outlined),
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
