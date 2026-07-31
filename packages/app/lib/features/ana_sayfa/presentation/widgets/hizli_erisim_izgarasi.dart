// Mockup'taki "Hızlı Erişim" ızgarası: 4 sütun x 2 satır, renkli daire ikon +
// alt yazı. İkon/renk eşlemesi burada (UI kararı) — hangi modülün aktif
// olduğu kararı ise domain'de (hizli_erisim_kurallari.dart).

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';
import '../../domain/hizli_erisim_kurallari.dart';

const Map<HizliErisimModulu, IconData> _ikonlar = {
  HizliErisimModulu.firmalar: Icons.business_outlined,
  HizliErisimModulu.harita: Icons.navigation_outlined,
  HizliErisimModulu.isIlanlari: Icons.work_outline,
  HizliErisimModulu.ikinciElPazar: Icons.storefront_outlined,
  HizliErisimModulu.cookzone: Icons.restaurant_outlined,
  // Palet Tesisi bir depo/envanter kavramı — kamyon ikonu "Paket Teslimi"
  // (kargo) izlenimi verirdi, kutu/envanter ikonuna çevrildi.
  HizliErisimModulu.paletTesisi: Icons.inventory_2_outlined,
  HizliErisimModulu.acilDurum: Icons.emergency_outlined,
  HizliErisimModulu.duyurular: Icons.campaign_outlined,
};

const Map<HizliErisimModulu, Color> _renkler = {
  HizliErisimModulu.firmalar: Renkler.lacivert,
  HizliErisimModulu.harita: Renkler.mavi,
  HizliErisimModulu.isIlanlari: Color(0xFF0F766E),
  HizliErisimModulu.ikinciElPazar: Color(0xFF9333EA),
  HizliErisimModulu.cookzone: Color(0xFFB45309),
  HizliErisimModulu.paletTesisi: Color(0xFF4F46E5),
  HizliErisimModulu.acilDurum: Color(0xFFBE123C),
  HizliErisimModulu.duyurular: Color(0xFF15803D),
};

class HizliErisimIzgarasi extends StatelessWidget {
  const HizliErisimIzgarasi({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 4,
      childAspectRatio: 0.78,
      children: [
        for (final modul in hizliErisimSirasi)
          _HizliErisimOgesi(
            modul: modul,
            ikon: _ikonlar[modul]!,
            renk: _renkler[modul]!,
          ),
      ],
    );
  }
}

class _HizliErisimOgesi extends StatelessWidget {
  const _HizliErisimOgesi({
    required this.modul,
    required this.ikon,
    required this.renk,
  });

  final HizliErisimModulu modul;
  final IconData ikon;
  final Color renk;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _basildi(context),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: renk.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(ikon, color: renk, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            modul.etiket,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.15,
              color: Renkler.lacivert,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _basildi(BuildContext context) {
    final rota = modul.rota;
    if (rota != null) {
      context.go(rota);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${modul.etiket.replaceAll('\n', ' ')} yakında')),
      );
  }
}
