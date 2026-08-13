// Kaynak: eski Expo app/(tabs)/_layout.tsx (expo-router <Tabs>) (silindi — bkz. docs/izlence-typescript-nestjs(1).md Ek A)
// go_router ShellRoute'un gövdesi: alt navigasyon + aktif sekmenin ekranı.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/durum/auth_durumu.dart';
import '../theme/renkler.dart';

class SekmeTanimi {
  const SekmeTanimi({
    required this.yol,
    required this.baslik,
    required this.ikon,
    required this.aktifIkon,
    this.kendiBasligiVar = false,
  });

  final String yol;
  final String baslik;
  final IconData ikon;
  final IconData aktifIkon;

  /// true ise bu sekmenin ekranı KENDİ başlığını/geri okunu zaten çiziyor
  /// (firmalar_ekrani.dart'taki AppBar, duyurular_ekrani.dart'taki gradyan
  /// _UstBaslik, profil_ekrani.dart'taki geri oku + "Profil" satırı gibi) —
  /// bu durumda SekmeKabugu KENDİ genel AppBar'ını göstermez, yoksa ekranda
  /// aynı başlık iki kez üst üste görünür (06.08.2026'da canlı test edilip
  /// bulundu). `false` olan sekmeler (Harita gibi) hâlâ bu genel AppBar'a
  /// muhtaç, o yüzden bu bayrak olmadan hepsi için kaldırılamaz.
  final bool kendiBasligiVar;
}

const List<SekmeTanimi> sekmeler = [
  SekmeTanimi(
    yol: '/',
    baslik: 'Ana Sayfa',
    ikon: Icons.home_outlined,
    aktifIkon: Icons.home,
  ),
  SekmeTanimi(
    yol: '/firmalar',
    baslik: 'Firmalar',
    ikon: Icons.business_center_outlined,
    aktifIkon: Icons.business_center,
    kendiBasligiVar: true,
  ),
  SekmeTanimi(
    yol: '/harita',
    baslik: 'Harita',
    ikon: Icons.location_on_outlined,
    aktifIkon: Icons.location_on,
  ),
  SekmeTanimi(
    yol: '/duyurular',
    baslik: 'Duyurular',
    ikon: Icons.campaign_outlined,
    aktifIkon: Icons.campaign,
    kendiBasligiVar: true,
  ),
  SekmeTanimi(
    yol: '/profil',
    baslik: 'Profil',
    ikon: Icons.person_outline,
    aktifIkon: Icons.person,
    kendiBasligiVar: true,
  ),
];

class SekmeKabugu extends ConsumerWidget {
  const SekmeKabugu({super.key, required this.cocuk});

  final Widget cocuk;

  int _aktifSekme(BuildContext context) {
    final konum = GoRouterState.of(context).matchedLocation;
    final indeks = sekmeler.indexWhere((s) => s.yol == konum);
    return indeks < 0 ? 0 : indeks;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aktif = _aktifSekme(context);

    // Oturum güvenli depodan okunmadan korumalı ekranları çizme —
    // yoksa yönlendirme kararı verilmeden içerik (ve API isteği) başlıyor.
    final authDurumu = ref.watch(authProvider);
    if (!authDurumu.hazir) {
      return const Scaffold(
        backgroundColor: Renkler.beyaz,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Alt sekme çubuğu HER ZAMAN görünür — girişsiz kullanıcı sadece '/'
    // (Ana Sayfa) rotasına erişebilir (bkz. yonlendirici.dart _acikRotalar),
    // diğer sekmelere basınca zaten /giris'e yönlendiriliyor. Ana Sayfa'nın
    // (aktif == 0) kendi hero banner'ı, `kendiBasligiVar: true` olan
    // sekmelerin de kendi başlığı olduğu için burada genel AppBar'ı
    // GÖSTERMİYORUZ — aksi halde iki başlık üst üste biner.
    return Scaffold(
      appBar: (aktif == 0 || sekmeler[aktif].kendiBasligiVar)
          ? null
          : AppBar(
              title: Text(sekmeler[aktif].baslik),
              backgroundColor: Renkler.beyaz,
              foregroundColor: Renkler.lacivert,
              elevation: 0,
            ),
      body: cocuk,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: aktif,
        onTap: (indeks) => context.go(sekmeler[indeks].yol),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Renkler.beyaz,
        selectedItemColor: Renkler.mavi,
        unselectedItemColor: Renkler.metinIkincil,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: [
          for (final sekme in sekmeler)
            BottomNavigationBarItem(
              icon: Icon(sekme.ikon),
              activeIcon: Icon(sekme.aktifIkon),
              label: sekme.baslik,
            ),
        ],
      ),
    );
  }
}
