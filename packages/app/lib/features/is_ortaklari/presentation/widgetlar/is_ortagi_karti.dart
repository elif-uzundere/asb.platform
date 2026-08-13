import 'package:flutter/material.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/is_ortagi_modeli.dart';

class IsOrtagiKarti extends StatelessWidget {
  const IsOrtagiKarti({
    required this.isOrtagi,
    this.onTap,
    this.genislik = 150,
    super.key,
  });

  final IsOrtagiModeli isOrtagi;
  final VoidCallback? onTap;
  final double genislik;

  @override
  Widget build(BuildContext context) {
    final renkler = Theme.of(context).colorScheme;

    return SizedBox(
      width: genislik,
      child: Material(
        color: renkler.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: renkler.outlineVariant,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.network(
                    medyaAdresiCozumle(isOrtagi.logoUrl),
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      return Container(
                        decoration: BoxDecoration(
                          color: renkler.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.business_rounded,
                          size: 38,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isOrtagi.ad,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}