// Görsel dil: duyurular_ekrani.dart/firmalar_ekrani.dart ile AYNI marka
// paleti ve kart deseni — lacivert→mavi degrade başlık + yumuşak gölgeli
// beyaz kartlar. Arama+konum filtresi duyurular_ekrani.dart'taki
// arama+kategori deseniyle AYNI: backend tek seferde tam listeyi döndürür
// (`GET /is-ilanlari` filtresiz), filtre client-side uygulanır — konum
// seçenekleri de zaten çekilmiş listeden türetilir, ayrı bir istek gitmez.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/models/favori_modelleri.dart';
import '../../../../core/models/is_ilani_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../../../auth/presentation/durum/auth_durumu.dart';
import '../../../favoriler/presentation/widgets/favori_kalp_butonu.dart';
import '../../domain/is_ilani_kurallari.dart';
import '../durum/is_ilani_liste_durumu.dart';
import '../durum/is_ilani_olustur_notifier.dart';

class IsIlanlariEkrani extends ConsumerStatefulWidget {
  const IsIlanlariEkrani({super.key});

  @override
  ConsumerState<IsIlanlariEkrani> createState() => _IsIlanlariEkraniDurumu();
}

class _IsIlanlariEkraniDurumu extends ConsumerState<IsIlanlariEkrani> {
  String? _seciliKonum;
  final _arama = TextEditingController();
  String _aramaMetni = '';

  @override
  void dispose() {
    _arama.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final durum = ref.watch(isIlanlariListesiProvider);
    final kullanici = ref.watch(authProvider).kullanici;
    final olusturabilirMi = ilanOlusturulabilirMi(kullanici);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _UstBaslik(
              adet: durum.valueOrNull?.length,
              olusturButonuGoster: olusturabilirMi,
              onOlusturBasildi: () => _olusturFormunuAc(context),
            ),
            Expanded(
              child: durum.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (hata, _) => _HataGorunumu(
                  mesaj: '$hata',
                  tekrarDene: () => ref.invalidate(isIlanlariListesiProvider),
                ),
                data: (ilanlar) {
                  if (ilanlar.isEmpty) return const _BosGorunum();

                  final konumlar = {
                    for (final i in ilanlar)
                      if (i.konum != null) i.konum!,
                  }.toList()
                    ..sort();

                  final aramaKucuk = _aramaMetni.trim().toLowerCase();
                  final gosterilecek = ilanlar.where((i) {
                    final konumUyuyor = _seciliKonum == null || i.konum == _seciliKonum;
                    final aramaUyuyor = aramaKucuk.isEmpty ||
                        i.baslik.toLowerCase().contains(aramaKucuk) ||
                        i.aciklama.toLowerCase().contains(aramaKucuk);
                    return konumUyuyor && aramaUyuyor;
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(isIlanlariListesiProvider),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      children: [
                        _AramaKutusu(
                          denetleyici: _arama,
                          degisti: (metin) => setState(() => _aramaMetni = metin),
                        ),
                        if (konumlar.length > 1) ...[
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: _KonumAcilirMenusu(
                              konumlar: konumlar,
                              secili: _seciliKonum,
                              secildi: (k) => setState(() => _seciliKonum = k),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        if (gosterilecek.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: _BosGorunum(
                              mesaj: aramaKucuk.isEmpty && _seciliKonum == null
                                  ? null
                                  : 'Filtreye uyan ilan bulunamadı',
                            ),
                          )
                        else
                          for (final ilan in gosterilecek) ...[
                            _IsIlaniKarti(
                              ilan: ilan,
                              tiklandi: () => context.push('/is-ilanlari/${ilan.id}'),
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

  void _olusturFormunuAc(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Renkler.beyaz,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _IlanOlusturFormu(),
    );
  }
}

/// firmalar_ekrani.dart'taki _AramaKutusu ile AYNI görsel desen.
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
          BoxShadow(color: Renkler.lacivert.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: denetleyici,
        onChanged: degisti,
        decoration: InputDecoration(
          hintText: 'İlan ara...',
          hintStyle: const TextStyle(color: Renkler.metinIkincil),
          prefixIcon: const Icon(Icons.search, color: Renkler.metinIkincil),
          filled: true,
          fillColor: Renkler.beyaz,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Renkler.mavi, width: 1.4),
          ),
        ),
      ),
    );
  }
}

/// firmalar_ekrani.dart'taki _SektorAcilirMenusu ile AYNI desen (ve aynı
/// null-sentinel çözümü — bkz. oradaki not).
class _KonumAcilirMenusu extends StatelessWidget {
  const _KonumAcilirMenusu({required this.konumlar, required this.secili, required this.secildi});

  final List<String> konumlar;
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
        for (final konum in konumlar) _menuOgesi(deger: konum, yazi: konum),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: Renkler.beyaz,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Renkler.kenarlik),
          boxShadow: [
            BoxShadow(color: Renkler.lacivert.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: Renkler.lacivert),
            const SizedBox(width: 6),
            Text(
              secili ?? 'Tüm konumlar',
              style: const TextStyle(color: Renkler.lacivert, fontWeight: FontWeight.w600, fontSize: 13),
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

class _UstBaslik extends StatelessWidget {
  const _UstBaslik({
    required this.adet,
    required this.olusturButonuGoster,
    required this.onOlusturBasildi,
  });

  /// null → henüz yükleniyor, sayaç gösterilmez.
  final int? adet;
  final bool olusturButonuGoster;
  final VoidCallback onOlusturBasildi;

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
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Renkler.beyaz),
              onPressed: () => context.go('/'),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İş İlanları',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Renkler.beyaz),
                    ),
                    const SizedBox(height: 6),
                    Container(width: 28, height: 2, color: Renkler.altin),
                    const SizedBox(height: 6),
                    Text(
                      adet == null ? 'Yükleniyor...' : '$adet ilan',
                      style: TextStyle(fontSize: 13, color: Renkler.beyaz.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ),
            if (olusturButonuGoster)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: InkWell(
                  onTap: onOlusturBasildi,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Renkler.beyaz.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Renkler.beyaz, size: 22),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _IsIlaniKarti extends StatelessWidget {
  const _IsIlaniKarti({required this.ilan, required this.tiklandi});

  final IsIlaniResponse ilan;
  final VoidCallback tiklandi;

  @override
  Widget build(BuildContext context) {
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
              BoxShadow(color: Renkler.lacivert.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Renkler.mavi.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.work_outline_rounded, color: Renkler.mavi, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ilan.baslik,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Renkler.lacivert),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ilan.firmaAdi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, color: Renkler.metinIkincil),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (ilan.konum != null) ...[
                          const Icon(Icons.location_on_outlined, size: 12, color: Renkler.metinIkincil),
                          const SizedBox(width: 3),
                          Text(ilan.konum!, style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil)),
                          const SizedBox(width: 10),
                        ],
                        const Icon(Icons.calendar_today_outlined, size: 12, color: Renkler.metinIkincil),
                        const SizedBox(width: 4),
                        Text(tarihiFormatla(ilan.yayinTarihi), style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              FavoriKalpButonu(tur: FavoriHedefTuru.isIlani, hedefId: ilan.id, boyut: 20),
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(color: Color(0xFFF5F5F5), shape: BoxShape.circle),
                child: const Icon(Icons.chevron_right, size: 18, color: Renkler.metinIkincil),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Modal bottom sheet içindeki form — yardim_destek_ekrani.dart'taki
/// _TalepOlusturFormu ile birebir aynı desen.
class _IlanOlusturFormu extends ConsumerStatefulWidget {
  const _IlanOlusturFormu();

  @override
  ConsumerState<_IlanOlusturFormu> createState() => _IlanOlusturFormuDurumu();
}

class _IlanOlusturFormuDurumu extends ConsumerState<_IlanOlusturFormu> {
  final _baslik = TextEditingController();
  final _aciklama = TextEditingController();
  final _konum = TextEditingController();

  @override
  void dispose() {
    _baslik.dispose();
    _aciklama.dispose();
    _konum.dispose();
    super.dispose();
  }

  void _gonder() => ref.read(isIlaniOlusturNotifierProvider.notifier).gonder(
        baslik: _baslik.text.trim(),
        aciklama: _aciklama.text.trim(),
        konum: _konum.text.trim(),
      );

  @override
  Widget build(BuildContext context) {
    ref.listen<IslemDurumu>(isIlaniOlusturNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'İlan oluşturulamadı',
        basariBasligi: 'İlan yayınlandı',
        basariMesaji: 'İş ilanınız yayınlandı, adaylar başvurabilir.',
        basariSonrasi: () => Navigator.of(context).pop(),
        sifirla: ref.read(isIlaniOlusturNotifierProvider.notifier).sifirla,
      );
    });

    final yukleniyor = ref.watch(isIlaniOlusturNotifierProvider) is IslemSuruyor;

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
          const Text(
            'Yeni İş İlanı',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Renkler.lacivert),
          ),
          const SizedBox(height: 16),
          GirdiKutusu(denetleyici: _baslik, ipucu: 'Pozisyon başlığı', ikon: Icons.work_outline_rounded),
          const SizedBox(height: 14),
          GirdiKutusu(denetleyici: _aciklama, ipucu: 'Pozisyon açıklaması', ikon: Icons.notes_rounded),
          const SizedBox(height: 14),
          GirdiKutusu(denetleyici: _konum, ipucu: 'Konum (opsiyonel)', ikon: Icons.location_on_outlined),
          const SizedBox(height: 18),
          BirincilButon(
            yazi: yukleniyor ? 'Yayınlanıyor...' : 'İlanı Yayınla',
            yukleniyor: yukleniyor,
            basildi: _gonder,
          ),
        ],
      ),
    );
  }
}

class _BosGorunum extends StatelessWidget {
  const _BosGorunum({this.mesaj});

  /// null ise liste gerçekten boş (hiç ilan yok); doluysa arama/filtre
  /// sonucu boş kaldı — ikisi FARKLI durumlar, kullanıcıya farklı anlatılmalı.
  final String? mesaj;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: Renkler.mavi.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(
              mesaj == null ? Icons.work_outline_rounded : Icons.search_off,
              size: 30,
              color: Renkler.mavi,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            mesaj ?? 'Henüz iş ilanı yok',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Renkler.metinIkincil, fontWeight: FontWeight.w500),
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
            child: Text(mesaj, textAlign: TextAlign.center, style: const TextStyle(color: Renkler.metinIkincil)),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: tekrarDene, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}
