// Görsel dil: firmalar_ekrani.dart/firma_detay_ekrani.dart ile AYNI marka
// paleti (Renkler.lacivert/mavi/altin) ve kart deseni (yumuşak gölgeli,
// köşeleri yuvarlak beyaz kart + ikon dairesi) — modül farklı ama "aynı
// uygulama" hissi korunuyor. Üstteki lacivert→mavi degrade başlık, firma
// detayındaki hero'nun küçük/liste versiyonu.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/duyuru_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../duyuru_gorseli.dart';
import '../durum/duyuru_durumu.dart';

class DuyurularEkrani extends ConsumerStatefulWidget {
  const DuyurularEkrani({super.key});

  @override
  ConsumerState<DuyurularEkrani> createState() => _DuyurularEkraniDurumu();
}

class _DuyurularEkraniDurumu extends ConsumerState<DuyurularEkrani> {
  String? _seciliKategori;

  @override
  Widget build(BuildContext context) {
    final durum = ref.watch(duyuruListesiProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _UstBaslik(adet: durum.valueOrNull?.length),
            Expanded(
              child: durum.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (hata, _) => _HataGorunumu(
                  mesaj: '$hata',
                  tekrarDene: () => ref.invalidate(duyuruListesiProvider),
                ),
                data: (duyurular) {
                  if (duyurular.isEmpty) return const _BosGorunum();

                  final kategoriler = {
                    for (final d in duyurular)
                      if (d.kategori != null) d.kategori!,
                  }.toList()
                    ..sort();

                  final gosterilecek = _seciliKategori == null
                      ? duyurular
                      : duyurular.where((d) => d.kategori == _seciliKategori).toList();

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(duyuruListesiProvider),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      children: [
                        if (kategoriler.length > 1) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _KategoriAcilirMenusu(
                              kategoriler: kategoriler,
                              secili: _seciliKategori,
                              secildi: (k) => setState(() => _seciliKategori = k),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (gosterilecek.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: _BosGorunum(),
                          )
                        else
                          for (final duyuru in gosterilecek) ...[
                            _DuyuruKarti(
                              duyuru: duyuru,
                              tiklandi: () => context.push('/duyurular/${duyuru.id}'),
                            ),
                            const SizedBox(height: 10),
                          ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Firma detayındaki hero'nun küçük/liste versiyonu — aynı degrade, aynı
/// alt köşe yuvarlaklığı (28) böylece "Duyurular" ekranı da aynı uygulamanın
/// bir parçası gibi hissettiriyor.
class _UstBaslik extends StatelessWidget {
  const _UstBaslik({required this.adet});

  /// null → henüz yükleniyor, sayaç gösterilmez.
  final int? adet;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Renkler.lacivert, Renkler.mavi],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Renkler.beyaz),
              onPressed: () => context.go('/'),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Duyurular',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Renkler.beyaz,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(width: 28, height: 2, color: Renkler.altin),
                  const SizedBox(height: 6),
                  Text(
                    adet == null ? 'Yükleniyor...' : '$adet duyuru',
                    style: TextStyle(
                      fontSize: 13,
                      color: Renkler.beyaz.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// firmalar_ekrani.dart'taki _SektorAcilirMenusu ile AYNI desen (ve aynı
/// null-sentinel çözümü — bkz. oradaki not: PopupMenuButton, showMenu'den
/// dönen değer null olduğunda "seçim yapılmadan kapatıldı" sanıp onSelected'i
/// hiç çağırmıyor; "Tümü" değeri gerçekten null olursa bir daha seçilemez
/// hale geliyordu. Bu yüzden null yerine sahte bir değer kullanılıyor).
class _KategoriAcilirMenusu extends StatelessWidget {
  const _KategoriAcilirMenusu({
    required this.kategoriler,
    required this.secili,
    required this.secildi,
  });

  final List<String> kategoriler;
  final String? secili;
  final ValueChanged<String?> secildi;

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
        for (final kategori in kategoriler) _menuOgesi(deger: kategori, yazi: kategori),
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
            const Icon(Icons.keyboard_arrow_down, size: 18, color: Renkler.lacivert),
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

class _DuyuruKarti extends StatelessWidget {
  const _DuyuruKarti({required this.duyuru, required this.tiklandi});

  final DuyuruResponse duyuru;
  final VoidCallback tiklandi;

  @override
  Widget build(BuildContext context) {
    final gorsel = kategoriGorseli(duyuru.kategori);

    return Material(
      color: Renkler.beyaz,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: tiklandi,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Renkler.lacivert.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: gorsel.renk.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(gorsel.ikon, color: gorsel.renk, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      duyuru.baslik,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Renkler.lacivert,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _KategoriCipi(
                          yazi: duyuru.kategori ?? 'Genel',
                          renk: gorsel.renk,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: Renkler.metinIkincil,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _tarihiFormatla(duyuru.yayinTarihi),
                          style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      duyuru.icerik,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Renkler.metinIkincil,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Renkler.metinIkincil,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KategoriCipi extends StatelessWidget {
  const _KategoriCipi({required this.yazi, required this.renk});

  final String yazi;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        yazi,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: renk),
      ),
    );
  }
}

class _BosGorunum extends StatelessWidget {
  const _BosGorunum();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Renkler.mavi.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.campaign_outlined, size: 30, color: Renkler.mavi),
          ),
          const SizedBox(height: 14),
          const Text(
            'Henüz duyuru yok',
            style: TextStyle(color: Renkler.metinIkincil, fontWeight: FontWeight.w500),
          ),
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
          const Icon(Icons.error_outline, size: 40, color: Renkler.metinIkincil),
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

String _tarihiFormatla(DateTime tarih) {
  String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
  return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year}';
}
