import 'package:flutter/material.dart';

import '../../../../core/models/firma_modelleri.dart';
import '../../../../core/theme/renkler.dart';
import 'firma_avatari.dart';

/// Liste ekranındaki her firma satırı. Sadece görünüm — dokununca ne
/// olacağına (detaya git) çağıran ekran karar veriyor.
///
/// Kenarlıklı düz kart yerine yumuşak gölgeli kart kullanılıyor — mockup'taki
/// kartlar da kenarlıksız, hafif gölgeli (bkz. Ana Sayfa "Öne Çıkanlar").
class FirmaKarti extends StatelessWidget {
  const FirmaKarti({super.key, required this.firma, required this.tiklandi});

  final FirmaResponse firma;
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
              BoxShadow(
                color: Renkler.lacivert.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              FirmaAvatari(firma: firma),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firma.ad,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Renkler.lacivert,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _SektorCipi(sektor: firma.sektor),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Renkler.metinIkincil,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            firma.adres,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Renkler.metinIkincil,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
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

class _SektorCipi extends StatelessWidget {
  const _SektorCipi({required this.sektor});

  final String sektor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Renkler.mavi.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        sektor,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Renkler.mavi,
        ),
      ),
    );
  }
}
