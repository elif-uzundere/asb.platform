import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/toplanma_alani.dart';
import '../providers/acil_durum_provider.dart';

class ToplanmaAlanlariEkrani extends ConsumerWidget {
  const ToplanmaAlanlariEkrani({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final alanlarAsync =
        ref.watch(toplanmaAlanlariProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF153773),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
          ),
        ),

        title: const Text(
          'Toplanma Alanları',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: alanlarAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        error: (hata, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Toplanma alanları yüklenemedi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  FilledButton(
                    onPressed: () {
                      ref.invalidate(
                        toplanmaAlanlariProvider,
                      );
                    },
                    child: const Text(
                      'Tekrar Dene',
                    ),
                  ),
                ],
              ),
            ),
          );
        },

        data: (alanlar) {
          return RefreshIndicator(
            onRefresh: () => ref.refresh(
              toplanmaAlanlariProvider.future,
            ),

            child: ListView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                22,
                16,
                32,
              ),
              children: [
                const _UstBilgi(),

                const SizedBox(height: 20),

                if (alanlar.isEmpty)
                  const _BosDurum()
                else
                  ...alanlar.map(
                    (alan) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: _ToplanmaAlaniKarti(
                        alan: alan,
                      ),
                    ),
                  ),

                if (alanlar.isNotEmpty) ...[
                  const SizedBox(height: 4),

                  const _BilgilendirmeKutusu(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UstBilgi extends StatelessWidget {
  const _UstBilgi();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _UstIkon(),

        SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toplanma Alanları',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 3),

              Text(
                'Acil Durum Toplanma Noktaları',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UstIkon extends StatelessWidget {
  const _UstIkon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: Color(0xFF2DA968),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.groups_rounded,
        color: Colors.white,
        size: 27,
      ),
    );
  }
}

class _ToplanmaAlaniKarti extends StatelessWidget {
  const _ToplanmaAlaniKarti({
    required this.alan,
  });

  final ToplanmaAlani alan;

  @override
  Widget build(BuildContext context) {
    final aciklamaVar =
        alan.aciklama != null &&
        alan.aciklama!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE7E9EE),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alan.ad,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          if (aciklamaVar) ...[
            const SizedBox(height: 5),

            Text(
              alan.aciklama!,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],

          const SizedBox(height: 14),

          InkWell(
            onTap: () {
              _haritadaGoster(
                context,
                alan,
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF2DA968),
                    size: 19,
                  ),

                  SizedBox(width: 7),

                  Text(
                    'Haritada Göster',
                    style: TextStyle(
                      color: Color(0xFF2DA968),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _haritadaGoster(
    BuildContext context,
    ToplanmaAlani alan,
  ) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/'
      '?api=1'
      '&query=${alan.enlem},${alan.boylam}',
    );

    final acildi = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!acildi && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Harita açılamadı.',
          ),
        ),
      );
    }
  }
}

class _BilgilendirmeKutusu
    extends StatelessWidget {
  const _BilgilendirmeKutusu();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF9F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFD1EEDD),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2DA968),
            size: 20,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Acil durum anında size en yakın '
              'toplanma alanına giderek yetkililerin '
              'yönlendirmelerini takip ediniz.',
              style: TextStyle(
                color: Color(0xFF365A44),
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BosDurum extends StatelessWidget {
  const _BosDurum();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE7E9EE),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            color: Color(0xFF98A2B3),
            size: 42,
          ),

          SizedBox(height: 12),

          Text(
            'Henüz toplanma alanı eklenmedi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF475467),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Toplanma alanları veritabanına '
            'eklendiğinde burada otomatik görünecek.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}