// Kaynak (tasarım): kullanıcının paylaştığı Yardım ve Destek ekran görüntüsü.
//
// Bu ekranda henüz gerçek bir "destek talebi" backend'i YOK — Profil
// ekranındaki diğer yapım-aşamasındaki menüler (Firmalarım, Başvurularım,
// Ayarlar vb.) gibi, o bölümler bilinçli olarak "yakında" bildirimi
// gösteriyor; sahte talep/sayı uydurmuyoruz. İletişim bilgileri ise GERÇEK
// (Ana Sayfa footer'ında kullanılanla aynı, doğrulanmış ASB verisi).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/renkler.dart';
import '../../data/destek_iletisim_servisi.dart';

const String _destekTelefonu = '+90 282 265 10 00';
const String _destekEpostasi = 'asb@asb.com.tr';
const String _destekAdresi =
    'Karamehmet Mah. Avrupa Serbest Bölgesi Adnan Arısoy '
    'Bulvarı No:1/1 59930 Ergene/Tekirdağ';

class YardimDestekEkrani extends ConsumerWidget {
  const YardimDestekEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iletisim = ref.read(destekIletisimServisiProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Column(
          children: [
            _UstBaslik(
              onGeri: () => Navigator.of(context).pop(),
              onKulaklikBasildi: () => iletisim.ara(_destekTelefonu),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _HeroKarti(),
                    const SizedBox(height: 16),
                    _DestekTalebiKarti(
                      onTap: () => _yakindaMesaji(context, 'Destek talebi oluşturma'),
                    ),
                    const SizedBox(height: 24),
                    _TaleplerimBaslik(
                      onTumunuGor: () => _yakindaMesaji(context, 'Taleplerim'),
                    ),
                    const SizedBox(height: 12),
                    const _TaleplerimSatiri(),
                    const SizedBox(height: 24),
                    const _BolumBasligi('Uygulama Hakkında'),
                    const SizedBox(height: 12),
                    _UygulamaHakkindaIzgarasi(
                      onBasildi: (baslik) => _yakindaMesaji(context, baslik),
                    ),
                    const SizedBox(height: 24),
                    const _BolumBasligi('Destek Konuları'),
                    const SizedBox(height: 12),
                    _DestekKonulariKarti(
                      onBasildi: (baslik) => _yakindaMesaji(context, baslik),
                    ),
                    const SizedBox(height: 24),
                    const _BolumBasligi('İletişim Bilgileri'),
                    const SizedBox(height: 12),
                    _IletisimBilgileriKarti(
                      onTelefonBasildi: () => iletisim.ara(_destekTelefonu),
                      onEpostaBasildi: () => iletisim.epostaGonder(_destekEpostasi),
                    ),
                    const SizedBox(height: 16),
                    _OnemliBilgilendirmeSeridi(
                      onTap: () => _yakindaMesaji(context, 'Gizlilik politikası'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _yakindaMesaji(BuildContext context, String konu) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$konu yakında eklenecek.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _UstBaslik extends StatelessWidget {
  const _UstBaslik({required this.onGeri, required this.onKulaklikBasildi});

  final VoidCallback onGeri;
  final VoidCallback onKulaklikBasildi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onGeri,
            icon: const Icon(Icons.arrow_back, color: Renkler.lacivert),
          ),
          const Expanded(
            child: Text(
              'Yardım ve Destek',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Renkler.lacivert,
              ),
            ),
          ),
          IconButton(
            onPressed: onKulaklikBasildi,
            tooltip: 'Bizi arayın',
            icon: const Icon(Icons.headset_mic_outlined, color: Renkler.lacivert),
          ),
        ],
      ),
    );
  }
}

class _HeroKarti extends StatelessWidget {
  const _HeroKarti();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Renkler.lacivert, Renkler.mavi],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buradayız, yardımcı\nolmaktan mutluluk duyarız.',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Renkler.beyaz,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Yaşadığınız sorunları bizimle paylaşın, '
                  'en kısa sürede dönüş yapalım.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFFCBD5E1)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Renkler.beyaz.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Renkler.beyaz,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _DestekTalebiKarti extends StatelessWidget {
  const _DestekTalebiKarti({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF5FC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_note_rounded, color: Renkler.mavi, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destek Talebi Oluştur',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Renkler.lacivert,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sorununuzu bize iletin, ekibimiz en kısa sürede '
                      'sizinle iletişime geçsin.',
                      style: TextStyle(fontSize: 12.5, color: Renkler.metinIkincil, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Renkler.lacivert,
                foregroundColor: Renkler.beyaz,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Yeni Talep Oluştur',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaleplerimBaslik extends StatelessWidget {
  const _TaleplerimBaslik({required this.onTumunuGor});

  final VoidCallback onTumunuGor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Taleplerim',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Renkler.lacivert),
        ),
        InkWell(
          onTap: onTumunuGor,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tümünü Gör', style: TextStyle(fontSize: 12.5, color: Renkler.mavi)),
              Icon(Icons.chevron_right_rounded, size: 18, color: Renkler.mavi),
            ],
          ),
        ),
      ],
    );
  }
}

/// Henüz gerçek bir destek-talebi backend'i yok — sıfır göstermek, sahte
/// sayı uydurmaktan daha doğru (bkz. dosya başındaki not).
class _TaleplerimSatiri extends StatelessWidget {
  const _TaleplerimSatiri();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: const Row(
        children: [
          Expanded(child: _TalepIstatistigi(ikon: Icons.description_outlined, renk: Renkler.mavi, deger: '0', etiket: 'Toplam')),
          Expanded(child: _TalepIstatistigi(ikon: Icons.access_time_rounded, renk: Renkler.altin, deger: '0', etiket: 'Beklemede')),
          Expanded(child: _TalepIstatistigi(ikon: Icons.check_circle_outline, renk: Color(0xFF16A34A), deger: '0', etiket: 'Yanıtlandı')),
          Expanded(child: _TalepIstatistigi(ikon: Icons.cancel_outlined, renk: Renkler.metinIkincil, deger: '0', etiket: 'Kapalı')),
        ],
      ),
    );
  }
}

class _TalepIstatistigi extends StatelessWidget {
  const _TalepIstatistigi({
    required this.ikon,
    required this.renk,
    required this.deger,
    required this.etiket,
  });

  final IconData ikon;
  final Color renk;
  final String deger;
  final String etiket;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(ikon, color: renk, size: 20),
        const SizedBox(height: 6),
        Text(deger, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Renkler.lacivert)),
        const SizedBox(height: 2),
        Text(etiket, style: const TextStyle(fontSize: 11, color: Renkler.metinIkincil)),
      ],
    );
  }
}

class _BolumBasligi extends StatelessWidget {
  const _BolumBasligi(this.yazi);

  final String yazi;

  @override
  Widget build(BuildContext context) {
    return Text(
      yazi,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Renkler.lacivert),
    );
  }
}

class _UygulamaHakkindaOgesi {
  const _UygulamaHakkindaOgesi({required this.ikon, required this.renk, required this.baslik, required this.aciklama});

  final IconData ikon;
  final Color renk;
  final String baslik;
  final String aciklama;
}

const List<_UygulamaHakkindaOgesi> _uygulamaHakkindaOgeleri = [
  _UygulamaHakkindaOgesi(
    ikon: Icons.shield_outlined,
    renk: Color(0xFF16A34A),
    baslik: 'Güvenlik',
    aciklama: 'Verilerinizin güvenliği bizim için önceliklidir.',
  ),
  _UygulamaHakkindaOgesi(
    ikon: Icons.notifications_none_rounded,
    renk: Color(0xFF7C3AED),
    baslik: 'Bildirim Tercihleri',
    aciklama: 'Bildirim ayarlarınızı düzenleyin.',
  ),
  _UygulamaHakkindaOgesi(
    ikon: Icons.info_outline_rounded,
    renk: Renkler.mavi,
    baslik: 'Sık Sorular',
    aciklama: 'En sık karşılaşılan sorunlara göz atın.',
  ),
];

class _UygulamaHakkindaIzgarasi extends StatelessWidget {
  const _UygulamaHakkindaIzgarasi({required this.onBasildi});

  final void Function(String baslik) onBasildi;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.65,
      children: [
        for (final oge in _uygulamaHakkindaOgeleri)
          _UygulamaHakkindaKart(oge: oge, onTap: () => onBasildi(oge.baslik)),
        _UygulamaHakkindaKart(
          oge: const _UygulamaHakkindaOgesi(
            ikon: Icons.sync_rounded,
            renk: Color(0xFF16A34A),
            baslik: 'Sürüm Bilgisi',
            aciklama: 'Sürüm 1.0.0',
          ),
          onTap: null,
        ),
      ],
    );
  }
}

class _UygulamaHakkindaKart extends StatelessWidget {
  const _UygulamaHakkindaKart({required this.oge, required this.onTap});

  final _UygulamaHakkindaOgesi oge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Renkler.beyaz,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7EAF0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(oge.ikon, color: oge.renk, size: 22),
              const SizedBox(height: 8),
              Text(
                oge.baslik,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Renkler.lacivert),
              ),
              const SizedBox(height: 2),
              Text(
                oge.aciklama,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, color: Renkler.metinIkincil),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DestekKonusuVerisi {
  const _DestekKonusuVerisi({required this.ikon, required this.baslik, required this.aciklama});

  final IconData ikon;
  final String baslik;
  final String aciklama;
}

const List<_DestekKonusuVerisi> _destekKonulari = [
  _DestekKonusuVerisi(
    ikon: Icons.person_outline_rounded,
    baslik: 'Giriş ve hesap sorunları',
    aciklama: 'Hesabınıza erişim, şifre ve profil ayarları hakkında bilgi alın.',
  ),
  _DestekKonusuVerisi(
    ikon: Icons.work_outline_rounded,
    baslik: 'Başvuru ve ilan işlemleri',
    aciklama: 'İlanlara başvuru, başvuru durumu ve süreçler hakkında destek alın.',
  ),
  _DestekKonusuVerisi(
    ikon: Icons.settings_outlined,
    baslik: 'Bildirim ve teknik sorunlar',
    aciklama: 'Bildirim ayarları, hata mesajları ve teknik sorunlara yönelik çözümler.',
  ),
];

class _DestekKonulariKarti extends StatelessWidget {
  const _DestekKonulariKarti({required this.onBasildi});

  final void Function(String baslik) onBasildi;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _destekKonulari.length; i++) ...[
            _DestekKonusuSatiri(veri: _destekKonulari[i], onTap: () => onBasildi(_destekKonulari[i].baslik)),
            if (i != _destekKonulari.length - 1)
              const Divider(height: 1, indent: 66, endIndent: 16, color: Color(0xFFE7EAF0)),
          ],
        ],
      ),
    );
  }
}

class _DestekKonusuSatiri extends StatelessWidget {
  const _DestekKonusuSatiri({required this.veri, required this.onTap});

  final _DestekKonusuVerisi veri;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(color: Color(0xFFEEF5FC), shape: BoxShape.circle),
                child: Icon(veri.ikon, color: Renkler.mavi, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(veri.baslik, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Renkler.lacivert)),
                    const SizedBox(height: 2),
                    Text(veri.aciklama, style: const TextStyle(fontSize: 12, color: Renkler.metinIkincil, height: 1.3)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF667085), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _IletisimBilgileriKarti extends StatelessWidget {
  const _IletisimBilgileriKarti({required this.onTelefonBasildi, required this.onEpostaBasildi});

  final VoidCallback onTelefonBasildi;
  final VoidCallback onEpostaBasildi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Renkler.beyaz,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        children: [
          _IletisimSatiri(
            ikon: Icons.call_outlined,
            baslik: 'Telefon',
            deger: _destekTelefonu,
            altYazi: 'Hafta içi 09:00 - 18:00',
            onTap: onTelefonBasildi,
          ),
          const Divider(height: 24, color: Color(0xFFE7EAF0)),
          _IletisimSatiri(
            ikon: Icons.mail_outline_rounded,
            baslik: 'E-posta',
            deger: _destekEpostasi,
            altYazi: 'En geç 24 saat içinde yanıtlarız.',
            onTap: onEpostaBasildi,
          ),
          const Divider(height: 24, color: Color(0xFFE7EAF0)),
          const _IletisimSatiri(
            ikon: Icons.location_on_outlined,
            baslik: 'Adres',
            deger: _destekAdresi,
            onTap: null,
          ),
        ],
      ),
    );
  }
}

class _IletisimSatiri extends StatelessWidget {
  const _IletisimSatiri({
    required this.ikon,
    required this.baslik,
    required this.deger,
    this.altYazi,
    this.onTap,
  });

  final IconData ikon;
  final String baslik;
  final String deger;
  final String? altYazi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: Renkler.mavi, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Renkler.lacivert)),
                const SizedBox(height: 2),
                Text(deger, style: const TextStyle(fontSize: 13, color: Renkler.lacivert)),
                if (altYazi != null) ...[
                  const SizedBox(height: 2),
                  Text(altYazi!, style: const TextStyle(fontSize: 11.5, color: Renkler.metinIkincil)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnemliBilgilendirmeSeridi extends StatelessWidget {
  const _OnemliBilgilendirmeSeridi({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEEF5FC),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Renkler.mavi, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Önemli Bilgilendirme', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Renkler.lacivert)),
                    SizedBox(height: 2),
                    Text(
                      'Gizliliğiniz bizim için önemlidir. Kişisel verileriniz '
                      'KVKK kapsamında korunmaktadır.',
                      style: TextStyle(fontSize: 11.5, color: Renkler.metinIkincil, height: 1.3),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Renkler.mavi, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
