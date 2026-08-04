// Giriş/kayıt/şifre ekranlarının ortak form parçaları.
// Ölçüler eski Expo kodundaki StyleSheet değerlerinden birebir alındı
// (girdi kutusu 46px, buton 48px, radius 10, kenarlık #E5E7EB).

import 'package:flutter/material.dart';

import '../theme/renkler.dart';

/// Giriş/Kayıt Ol hero görselinin üstüne bindirilen geri/kapat düğmesi —
/// bu ekranlar ShellRoute DIŞINda olduğu için alt sekme çubuğu yok, kullanıcı
/// Profil sekmesine dönebilsin diye eklendi.
class GeriButonu extends StatelessWidget {
  const GeriButonu({super.key, required this.basildi});

  final VoidCallback basildi;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: basildi,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Renkler.beyaz, size: 20),
      ),
    );
  }
}

class GirdiKutusu extends StatelessWidget {
  const GirdiKutusu({
    super.key,
    required this.denetleyici,
    required this.ipucu,
    this.ikon,
    this.sonEk,
    this.gizli = false,
    this.klavyeTipi,
    this.otomatikDoldurma,
  });

  final TextEditingController denetleyici;
  final String ipucu;
  final IconData? ikon;
  final Widget? sonEk;
  final bool gizli;
  final TextInputType? klavyeTipi;
  final List<String>? otomatikDoldurma;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Renkler.kenarlik),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (ikon != null) ...[
            Icon(ikon, size: 18, color: Renkler.metinIkincil),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: denetleyici,
              obscureText: gizli,
              keyboardType: klavyeTipi,
              autofillHints: otomatikDoldurma,
              textCapitalization: klavyeTipi == TextInputType.emailAddress
                  ? TextCapitalization.none
                  : TextCapitalization.sentences,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: ipucu,
                hintStyle:
                    const TextStyle(fontSize: 14, color: Renkler.metinIkincil),
              ),
            ),
          ),
          if (sonEk != null) ...[const SizedBox(width: 8), sonEk!],
        ],
      ),
    );
  }
}

/// Şifre alanlarındaki göz (göster/gizle) düğmesi.
class SifreGozu extends StatelessWidget {
  const SifreGozu({super.key, required this.gorunur, required this.degistir});

  final bool gorunur;
  final VoidCallback degistir;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: degistir,
      child: Icon(
        gorunur ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 18,
        color: Renkler.metinIkincil,
      ),
    );
  }
}

class BirincilButon extends StatelessWidget {
  const BirincilButon({
    super.key,
    required this.yazi,
    required this.basildi,
    this.yukleniyor = false,
  });

  final String yazi;
  final VoidCallback basildi;
  final bool yukleniyor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: yukleniyor ? null : basildi,
        style: ElevatedButton.styleFrom(
          backgroundColor: Renkler.lacivert,
          disabledBackgroundColor: Renkler.lacivert.withValues(alpha: 0.6),
          foregroundColor: Renkler.beyaz,
          disabledForegroundColor: Renkler.beyaz,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          yazi,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

/// "veya" + 3 sosyal düğme. OAuth henüz yok (Adım 4b'ye ertelendi),
/// düğmeler "Yakında" mesajı gösteriyor — eski Expo kodu ile aynı davranış.
class SosyalGirisSatiri extends StatelessWidget {
  const SosyalGirisSatiri({super.key, required this.yakindaMesaji});

  final String yakindaMesaji;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'veya',
          style: TextStyle(fontSize: 12, color: Renkler.metinIkincil),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SosyalButon(
              icerik: const Text(
                'G',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Renkler.lacivert,
                ),
              ),
              basildi: () => _yakinda(context),
            ),
            const SizedBox(width: 14),
            _SosyalButon(
              icerik: const Text(
                'in',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Renkler.lacivert,
                ),
              ),
              basildi: () => _yakinda(context),
            ),
            const SizedBox(width: 14),
            _SosyalButon(
              icerik: const Icon(Icons.apple, size: 18, color: Renkler.lacivert),
              basildi: () => _yakinda(context),
            ),
          ],
        ),
      ],
    );
  }

  void _yakinda(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(yakindaMesaji)));
  }
}

class _SosyalButon extends StatelessWidget {
  const _SosyalButon({required this.icerik, required this.basildi});

  final Widget icerik;
  final VoidCallback basildi;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: basildi,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Renkler.kenarlik),
        ),
        alignment: Alignment.center,
        child: icerik,
      ),
    );
  }
}
