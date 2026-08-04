// Kaynak: eski Expo app/(tabs)/firmalar.tsx (silindi — bkz. izlence Ek A)
//
// Bu dosya SADECE görünüm: arama kutusunu ve sektör çiplerini gösterir,
// FirmaListeNotifier'a bildirir, durumu dinler. Debounce/sorgu birleştirme
// gibi mantık notifier'da (bkz. presentation/durum/firma_liste_durumu.dart).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/firma_modelleri.dart';
import '../../../../core/router/route_gozlemci.dart';
import '../../../../core/theme/renkler.dart';
import '../durum/firma_liste_durumu.dart';
import '../widgets/firma_karti.dart';
import '../widgets/firma_karti_iskeleti.dart';

class FirmalarEkrani extends ConsumerStatefulWidget {
  const FirmalarEkrani({super.key});

  @override
  ConsumerState<FirmalarEkrani> createState() => _FirmalarEkraniDurumu();
}

// RouteAware: "üstüme açılan bir sayfa kapandı, kullanıcı bana geri döndü"
// anını (didPopNext) yakalamak için. Neden gerekli: /firmalar/:id detay
// ekranı ShellRoute DIŞINDA, yani bu ekranın widget'ı bellekte KALIYOR
// (dispose olmuyor) — sadece üstü kapanıyor. autoDispose provider bu yüzden
// kendiliğinden tetiklenmiyor, elle tetiklememiz gerekiyor. (Sekmeler arası
// geçişte ayrı bir sorun yok: ShellRoute her sekme değişiminde bu widget'ı
// zaten yeniden kuruyor, autoDispose provider da o an sıfırdan veri çekiyor.)
class _FirmalarEkraniDurumu extends ConsumerState<FirmalarEkrani>
    with RouteAware {
  late final TextEditingController _arama;

  @override
  void initState() {
    super.initState();
    _arama = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeGozlemci.subscribe(this, route);
  }

  @override
  void didPopNext() {
    // Detay ekranından (veya üstüne açılan başka bir sayfadan) geri dönüldü.
    ref.read(firmaListeNotifierProvider.notifier).disaridanYenile();
  }

  @override
  void dispose() {
    routeGozlemci.unsubscribe(this);
    _arama.dispose();
    super.dispose();
  }

  /// "Filtreyi temizle"nin çağırdığı yer. notifier'ın kendi `filtreleriTemizle`
  /// metodu SADECE sorgu state'ini sıfırlıyor — TextEditingController widget'a
  /// ait ayrı bir nesne olduğu için notifier onu göremiyor/temizleyemiyor.
  /// Burada ikisini birlikte yapmak zorundayız, yoksa arama kutusu eski
  /// metni göstermeye devam ederken liste sessizce filtresiz sonuç gösterir
  /// — kullanıcıyı yanıltan bir tutarsızlık.
  void _filtreleriTemizle(FirmaListeNotifier notifier) {
    _arama.clear();
    notifier.filtreleriTemizle();
  }

  @override
  Widget build(BuildContext context) {
    final durum = ref.watch(firmaListeNotifierProvider);
    final notifier = ref.read(firmaListeNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Firmalar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: _AramaKutusu(
                denetleyici: _arama,
                degisti: notifier.aramaDegisti,
              ),
            ),
            _SektorFiltreSatiri(
              secili: notifier.seciliSektor,
              secildi: notifier.sektorSecildi,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: switch (durum) {
                FirmaListeYukleniyor() => const _YukleniyorListesi(),
                FirmaListeHatali(:final mesaj) => _HataGorunumu(
                  mesaj: mesaj,
                  tekrarDene: () => notifier.aramaDegisti(notifier.aramaMetni),
                ),
                FirmaListeHazir(:final firmalar) =>
                  firmalar.isEmpty
                      ? _SonucYok(temizle: () => _filtreleriTemizle(notifier))
                      : _FirmaListesi(firmalar: firmalar),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AramaKutusu extends StatelessWidget {
  const _AramaKutusu({required this.denetleyici, required this.degisti});

  final TextEditingController denetleyici;
  final ValueChanged<String> degisti;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Renkler.lacivert.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: denetleyici,
        onChanged: degisti,
        decoration: InputDecoration(
          hintText: 'Firma ara...',
          hintStyle: const TextStyle(color: Renkler.metinIkincil),
          prefixIcon: const Icon(Icons.search, color: Renkler.metinIkincil),
          filled: true,
          fillColor: Renkler.beyaz,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Renkler.mavi, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _SektorFiltreSatiri extends ConsumerWidget {
  const _SektorFiltreSatiri({required this.secili, required this.secildi});

  final String? secili;
  final ValueChanged<String?> secildi;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sektorler = ref.watch(sektorlerProvider);

    return sektorler.when(
      // Sektör menüsü yüklenemese de liste çalışmaya devam etsin — sessizce
      // boş bırakılıyor, ayrıca bir hata ekranı gerekmiyor.
      loading: () => const SizedBox(height: 40),
      error: (_, _) => const SizedBox.shrink(),
      data: (liste) {
        if (liste.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: _SektorAcilirMenusu(
              secili: secili,
              secenekler: liste,
              secildi: secildi,
            ),
          ),
        );
      },
    );
  }
}

/// Çip satırı ekrana sığmıyordu; tek satırlık açılır menüye çevrildi —
/// tüm sektörler artık kaydırmaya gerek kalmadan bir dokunuşla görünüyor.
class _SektorAcilirMenusu extends StatelessWidget {
  const _SektorAcilirMenusu({
    required this.secili,
    required this.secenekler,
    required this.secildi,
  });

  final String? secili;
  final List<String> secenekler;
  final ValueChanged<String?> secildi;

  // PopupMenuButton, showMenu'den dönen değer null olduğunda bunu "kullanıcı
  // menüyü seçim yapmadan kapattı" olarak yorumluyor ve onSelected'i HİÇ
  // çağırmıyor (bkz. Flutter framework: newValue == null → onCanceled).
  // "Tümü" seçeneğinin değeri gerçekten null olursa bir daha asla seçilemez
  // hale geliyordu — bu yüzden null yerine bu sahte değer kullanılıyor ve
  // sadece dışarı aktarırken null'a çevriliyor.
  static const _tumuDegeri = '__tumu__';

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: secili ?? _tumuDegeri,
      onSelected: (deger) => secildi(deger == _tumuDegeri ? null : deger),
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) => [
        _menuOgesi(deger: _tumuDegeri, yazi: 'Tümü'),
        for (final sektor in secenekler) _menuOgesi(deger: sektor, yazi: sektor),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Renkler.beyaz,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Renkler.kenarlik),
          boxShadow: [
            BoxShadow(
              color: Renkler.lacivert.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.filter_list, size: 16, color: Renkler.lacivert),
            const SizedBox(width: 6),
            Text(
              secili ?? 'Tümü',
              style: const TextStyle(
                color: Renkler.lacivert,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: Renkler.lacivert,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuOgesi({required String deger, required String yazi}) {
    final seciliMi = deger == (secili ?? _tumuDegeri);
    return PopupMenuItem<String>(
      value: deger,
      child: Row(
        children: [
          Expanded(
            child: Text(
              yazi,
              style: TextStyle(
                color: seciliMi ? Renkler.lacivert : Colors.black87,
                fontWeight: seciliMi ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          if (seciliMi) const Icon(Icons.check, size: 18, color: Renkler.lacivert),
        ],
      ),
    );
  }
}

class _YukleniyorListesi extends StatelessWidget {
  const _YukleniyorListesi();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => const FirmaKartiIskeleti(),
    );
  }
}

class _FirmaListesi extends StatelessWidget {
  const _FirmaListesi({required this.firmalar});

  final List<FirmaResponse> firmalar;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: firmalar.length + 1,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2),
            child: Text(
              '${firmalar.length} firma bulundu',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Renkler.metinIkincil,
              ),
            ),
          );
        }
        final firma = firmalar[index - 1];
        return FirmaKarti(
          firma: firma,
          tiklandi: () => context.push('/firmalar/${firma.id}'),
        );
      },
    );
  }
}

class _SonucYok extends StatelessWidget {
  const _SonucYok({required this.temizle});

  final VoidCallback temizle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 40, color: Renkler.metinIkincil),
          const SizedBox(height: 12),
          const Text(
            'Aradığın firma bulunamadı',
            style: TextStyle(color: Renkler.metinIkincil),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: temizle, child: const Text('Filtreyi temizle')),
        ],
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
          const Icon(
            Icons.error_outline,
            size: 40,
            color: Renkler.metinIkincil,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              mesaj,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Renkler.metinIkincil),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: tekrarDene, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}
