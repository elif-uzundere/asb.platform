// Firma detay ekranı. Derin link için GET /firmalar/{id} kullanır (listeden
// taşınan nesneyle değil) — biri /firmalar/abc123 adresini paylaşırsa ya da
// uygulama o adresle soğuk açılırsa listeden taşınacak bir veri olmaz.
// (Şifre sıfırlama linkinde tam bu yüzden bir hataya düşmüştük, aynı
// tuzağa burada düşülmüyor — bkz. docs/CLAUDE.md derin link kararı.)
//
// Görsel dil: lacivert→mavi degrade "hero" + üstüne taşan TAM GENİŞLİKTE beyaz
// raf. Bu, giris_ekrani.dart'taki hero-görsel + taşan kart deseninin BİREBİR
// aynısı (aynı radius: 28, aynı Transform.translate(-28) tekniği) — hero'nun
// kendisi düz bir dikdörtgen, yuvarlaklık SADECE üstteki beyaz rafın üst
// köşelerinde. Daha önce hero'nun kendisine de ayrı bir köşe/oval kesim
// eklenmişti; iki farklı şeklin (hero'nun kavisi + kartın köşesi) hizasız
// kalması "iki ayrı parça" gibi görünmesine yol açıyordu. Tek taraflı
// yuvarlaklık + sıfır boşluk = kesintisiz geçiş.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/firma_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import '../../data/firma_iletisim_servisi.dart';
import '../durum/firma_detay_durumu.dart';
import '../widgets/firma_avatari.dart';

class FirmaDetayEkrani extends ConsumerWidget {
  const FirmaDetayEkrani({super.key, required this.firmaId});

  final String firmaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detay = ref.watch(firmaDetayProvider(firmaId));

    return detay.when(
      loading: () => const _BasitIskelet(),
      error: (hata, _) => _BasitHata(mesaj: '$hata'),
      data: (firma) => _FirmaDetaySayfasi(firma: firma),
    );
  }
}

/// Yükleniyor/hata durumlarında hero'yu çizecek veri yok — sade bir AppBar
/// yeterli, gölge/degrade gibi süslemeler burada gereksiz.
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

class _FirmaDetaySayfasi extends ConsumerWidget {
  const _FirmaDetaySayfasi({required this.firma});

  final FirmaResponse firma;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iletisim = ref.read(firmaIletisimServisiProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Renkler.lacivert,
            foregroundColor: Renkler.beyaz,
            elevation: 0,
            expandedHeight: 232,
            flexibleSpace: FlexibleSpaceBar(
              background: _HeroArkaPlani(firma: firma),
            ),
          ),
          SliverToBoxAdapter(
            // giris_ekrani.dart ile AYNI değer (-28) — hero'nun altındaki
            // rafın üst köşeleri (radius 28) tam bu kadar taşınca kesintisiz
            // görünüyor. Boşluk da yok, hizasızlık da yok.
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Column(
                children: [
                  _HizliAksiyonlarRafi(firma: firma, iletisim: iletisim),
                  const SizedBox(height: 12),
                  _IletisimKarti(firma: firma),
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

/// Degrade "hero" bölgesi: avatar, ad, sektör çipi. SliverAppBar toplandığında
/// (kullanıcı aşağı kaydırdığında) bu alan kaybolur, sadece lacivert şerit +
/// geri butonu kalır — modern uygulamalarda yaygın bir profil başlığı deseni.
///
/// BİLEREK düz dikdörtgen — köşe yuvarlaklığı SADECE üstüne taşan beyaz rafta
/// (bkz. `_HizliAksiyonlarRafi`). İki ayrı şekle iki ayrı köşe/kavis vermek
/// hizasızlığa yol açıyordu (bir önceki oval deneme).
class _HeroArkaPlani extends StatelessWidget {
  const _HeroArkaPlani({required this.firma});

  final FirmaResponse firma;

  @override
  Widget build(BuildContext context) {
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
                child: FirmaAvatari(firma: firma, boyut: 76),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  firma.ad,
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
              // İnce altın çizgi — markanın üçüncü rengi (Renkler.altin),
              // ada ile sektör çipi arasında küçük bir ayraç olarak.
              Container(width: 28, height: 2, color: Renkler.altin),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Renkler.beyaz.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Renkler.beyaz.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  firma.sektor,
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

/// Hero'nun altına kesintisiz devam eden, TAM GENİŞLİKTE beyaz raf. Sadece üst
/// köşeleri yuvarlak (giriş ekranındaki hero-kart geçişiyle aynı radius: 28)
/// ve yatay boşluğu yok — bu yüzden hero'nun düz alt kenarına birebir oturuyor.
class _HizliAksiyonlarRafi extends StatelessWidget {
  const _HizliAksiyonlarRafi({required this.firma, required this.iletisim});

  final FirmaResponse firma;
  final FirmaIletisimServisi iletisim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Üst boşluk alttan fazla — ikonlar hero ile birleştiği kenara
      // (yuvarlak köşenin hemen altına) çok yapışık duruyordu, aşağı
      // ittirildi ki nefes alan bir boşluk olsun.
      padding: const EdgeInsets.only(top: 30, bottom: 16),
      decoration: const BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Telefon yoksa "Ara" düğmesi hiç görünmüyor — null alanlar için
          // sahte/pasif buton göstermek yerine tamamen gizleniyor.
          if (firma.telefon != null)
            _HizliAksiyon(
              ikon: Icons.call_outlined,
              yazi: 'Ara',
              basildi: () => iletisim.ara(firma.telefon!),
            ),
          if (firma.eposta != null)
            _HizliAksiyon(
              ikon: Icons.mail_outline,
              yazi: 'E-posta',
              basildi: () => iletisim.epostaGonder(firma.eposta!),
            ),
          if (firma.webAdres != null)
            _HizliAksiyon(
              ikon: Icons.language_outlined,
              yazi: 'Web Sitesi',
              basildi: () => iletisim.webSitesiniAc(firma.webAdres!),
            ),
          _HizliAksiyon(
            ikon: Icons.copy_outlined,
            yazi: 'Adresi kopyala',
            basildi: () => _adresiKopyala(context, firma.adres),
          ),
        ],
      ),
    );
  }

  void _adresiKopyala(BuildContext context, String adres) {
    Clipboard.setData(ClipboardData(text: adres));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Adres kopyalandı')));
  }
}

class _HizliAksiyon extends StatelessWidget {
  const _HizliAksiyon({
    required this.ikon,
    required this.yazi,
    required this.basildi,
  });

  final IconData ikon;
  final String yazi;
  final VoidCallback basildi;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: basildi,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Renkler.mavi.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(ikon, color: Renkler.lacivert, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              yazi,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil),
            ),
          ],
        ),
      ),
    );
  }
}

class _IletisimKarti extends StatelessWidget {
  const _IletisimKarti({required this.firma});

  final FirmaResponse firma;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Renkler.lacivert.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'İLETİŞİM',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Renkler.metinIkincil,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          _IletisimSatiri(
            ikon: Icons.location_on_outlined,
            baslik: 'Adres',
            deger: firma.adres,
          ),
          // Telefon/e-posta null ise satır tamamen gizli — "Belirtilmemiş"
          // yazmıyoruz, alan hiç yokmuş gibi davranıyoruz.
          if (firma.telefon != null) ...[
            const SizedBox(height: 14),
            _IletisimSatiri(
              ikon: Icons.call_outlined,
              baslik: 'Telefon',
              deger: firma.telefon!,
            ),
          ],
          if (firma.eposta != null) ...[
            const SizedBox(height: 14),
            _IletisimSatiri(
              ikon: Icons.mail_outline,
              baslik: 'E-posta',
              deger: firma.eposta!,
            ),
          ],
          if (firma.webAdres != null) ...[
            const SizedBox(height: 14),
            _IletisimSatiri(
              ikon: Icons.language_outlined,
              baslik: 'Web Sitesi',
              deger: firma.webAdres!,
            ),
          ],
          if (firma.kurulusTarihi != null) ...[
            const SizedBox(height: 14),
            _IletisimSatiri(
              ikon: Icons.event_outlined,
              baslik: 'Kuruluş Tarihi',
              deger: _tarihiFormatla(firma.kurulusTarihi!),
            ),
          ],
          if (firma.personelSayisi != null) ...[
            const SizedBox(height: 14),
            _IletisimSatiri(
              ikon: Icons.groups_outlined,
              baslik: 'Personel Sayısı',
              deger: '${firma.personelSayisi} kişi',
            ),
          ],
        ],
      ),
    );
  }
}

/// `intl` paketine ihtiyaç duymayan minik bir GG.AA.YYYY biçimlendirici —
/// sadece bu tek yerde kullanıldığı için ayrı bir bağımlılık eklemeye değmedi.
String _tarihiFormatla(DateTime tarih) {
  String ikiHane(int sayi) => sayi.toString().padLeft(2, '0');
  return '${ikiHane(tarih.day)}.${ikiHane(tarih.month)}.${tarih.year}';
}

class _IletisimSatiri extends StatelessWidget {
  const _IletisimSatiri({
    required this.ikon,
    required this.baslik,
    required this.deger,
  });

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
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            shape: BoxShape.circle,
          ),
          child: Icon(ikon, size: 16, color: Renkler.metinIkincil),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                baslik,
                style: const TextStyle(
                  fontSize: 12,
                  color: Renkler.metinIkincil,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                deger,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
