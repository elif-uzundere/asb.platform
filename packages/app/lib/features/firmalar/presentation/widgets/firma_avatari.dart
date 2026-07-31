// Logo yoksa gösterilen baş harf avatarı. seed'deki 8 firmanın hiçbirinde
// logoUrl yok — yani bu varsayılan durum, istisna değil; bu yüzden ayrı
// bir widget olarak burada.

import 'package:flutter/material.dart';

import '../../../../core/models/firma_modelleri.dart';
import '../../domain/firma_kurallari.dart';

/// Firma adından türetilen 6 renklik sabit palet — aynı firma her zaman aynı
/// rengi alır, farklı firmalar görsel olarak ayrışır (bkz. avatarRengiIndeksi).
const List<Color> _avatarRenkleri = [
  Color(0xFF042C53), // lacivert
  Color(0xFF1E7FD8), // mavi
  Color(0xFF0F766E), // teal
  Color(0xFF9333EA), // mor
  Color(0xFFB45309), // amber koyu
  Color(0xFFBE123C), // kırmızımsı
];

class FirmaAvatari extends StatelessWidget {
  const FirmaAvatari({super.key, required this.firma, this.boyut = 48});

  final FirmaResponse firma;
  final double boyut;

  @override
  Widget build(BuildContext context) {
    final logoUrl = firma.logoUrl;

    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          logoUrl,
          width: boyut,
          height: boyut,
          fit: BoxFit.cover,
          // Logo adresi bozuksa/erişilemezse baş harflere düş — kırık resim
          // ikonu göstermek yerine.
          errorBuilder: (context, hata, iz) => _basHarfDairesi(),
        ),
      );
    }

    return _basHarfDairesi();
  }

  Widget _basHarfDairesi() {
    final renk = _avatarRenkleri[firma.avatarRengiIndeksi];
    return Container(
      width: boyut,
      height: boyut,
      decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        firma.basHarfler,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: boyut * 0.36,
        ),
      ),
    );
  }
}
