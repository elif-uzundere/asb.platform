import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/acil_durum_birimi.dart';
import '../providers/acil_durum_provider.dart';

class AcilDurumEkrani extends ConsumerWidget {
  const AcilDurumEkrani({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final birimlerAsync =
        ref.watch(acilDurumBirimleriProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
  backgroundColor: const Color(0xFF102F68),
  foregroundColor: Colors.white,
  centerTitle: true,
  elevation: 0,

  leading: IconButton(
    onPressed: () {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    },
    icon: const Icon(
      Icons.arrow_back_ios_new_rounded,
      color: Colors.white,
      size: 20,
    ),
  ),

  title: const Text(
    'Acil Durum',
    style: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
  ),

  actions: [
    IconButton(
      onPressed: () => context.push('/acil-durum/bildirimlerim'),
      icon: const Icon(Icons.history_rounded, color: Colors.white, size: 22),
      tooltip: 'Bildirimlerim',
    ),
  ],
),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/acil-durum/bildir'),
        backgroundColor: const Color(0xFFF04444),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.campaign_rounded),
        label: const Text('Acil Durum Bildir', style: TextStyle(fontWeight: FontWeight.w700)),
      ),

      body: birimlerAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        error: (hata, _) {
          return Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(24),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Bilgiler yüklenemedi.',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  FilledButton(
                    onPressed: () {
                      ref.invalidate(
                        acilDurumBirimleriProvider,
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

        data: (birimlerHam) {
          // Backend `sira` diye bir kolon tutmuyor (bkz. AcilDurumBirimi.jsondan
          // — `sira` sadece Flutter tarafında `tur`'a göre türetilen sabit bir
          // değer), bu yüzden DB'nin dönüş sırasına güvenmek yerine burada
          // açıkça sıralanıyor (13.08.2026, mockup'taki sıra korunsun diye).
          final birimler = [...birimlerHam]
            ..sort((a, b) => a.sira.compareTo(b.sira));

          final acilBirimler = birimler
    .where(
      (birim) =>
          birim.tur == 'isg' ||
          birim.tur == 'itfaiye' ||
          birim.tur == 'guvenlik' ||
          birim.tur == 'musteri_hizmetleri',
    )
    .toList();

final digerBirimler = birimler
    .where(
      (birim) =>
          birim.tur == 'kantar' ||
          birim.tur == 'gumruk',
    )
    .toList();

          return RefreshIndicator(
            onRefresh: () => ref.refresh(
              acilDurumBirimleriProvider.future,
            ),
            child: ListView(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                32,
              ),
              children: [
                const _BolumBasligi(
                  'ACİL DURUM',
                ),

                const SizedBox(height: 10),

                _BirimGrubu(
                  birimler: acilBirimler,
                ),

                const SizedBox(height: 26),

                const _BolumBasligi(
                  'DİĞER HIZLI BİLGİLER',
                ),

                const SizedBox(height: 10),

                _DigerBilgilerGrubu(
                  birimler: digerBirimler,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BolumBasligi extends StatelessWidget {
  const _BolumBasligi(
    this.baslik,
  );

  final String baslik;

  @override
  Widget build(BuildContext context) {
    return Text(
      baslik,
      style: const TextStyle(
        color: Color(0xFF15223D),
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _BirimGrubu extends StatelessWidget {
  const _BirimGrubu({
    required this.birimler,
  });

  final List<AcilDurumBirimi> birimler;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (
            int i = 0;
            i < birimler.length;
            i++
          ) ...[
            _BirimSatiri(
              birim: birimler[i],
            ),

            if (i !=
                birimler.length - 1)
              const Divider(
                height: 1,
                indent: 64,
                color:
                    Color(0xFFE9EAEC),
              ),
          ],
        ],
      ),
    );
  }
}

class _DigerBilgilerGrubu
    extends StatelessWidget {
  const _DigerBilgilerGrubu({
    required this.birimler,
  });

  final List<AcilDurumBirimi> birimler;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color:
              const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (final birim
              in birimler) ...[
            _BirimSatiri(
              birim: birim,
            ),

            const Divider(
              height: 1,
              indent: 64,
              color: Color(0xFFE9EAEC),
            ),
          ],

          const _ToplanmaAlanlariSatiri(),
        ],
      ),
    );
  }
}

class _BirimSatiri extends StatelessWidget {
  const _BirimSatiri({
    required this.birim,
  });

  final AcilDurumBirimi birim;

  @override
  Widget build(BuildContext context) {
    final renk =
        _birimRengi(birim.tur);

    return InkWell(
      onTap: () {
        context.push(
          '/acil-durum/birim',
          extra: birim,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: renk,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _birimIkonu(
                  birim.tur,
                ),
                color: Colors.white,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    birim.ad,
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF111827),
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    birim.altBaslik,
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF667085),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color:
                  Color(0xFF667085),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToplanmaAlanlariSatiri
    extends StatelessWidget {
  const _ToplanmaAlanlariSatiri();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push(
          '/acil-durum/toplanma-alanlari',
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        child: Row(
          children: [
            _ToplanmaIkonu(),

            SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toplanma Alanları',
                    style: TextStyle(
                      color:
                          Color(0xFF111827),
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'Toplanma alanlarının listesi',
                    style: TextStyle(
                      color:
                          Color(0xFF667085),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right,
              color:
                  Color(0xFF667085),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToplanmaIkonu
    extends StatelessWidget {
  const _ToplanmaIkonu();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFF2AAFC0),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.location_on_outlined,
        color: Colors.white,
        size: 21,
      ),
    );
  }
}

Color _birimRengi(String tur) {
  switch (tur) {
    case 'isg':
      return const Color(0xFF2DA968);

    case 'itfaiye':
      return const Color(0xFFF04444);

    case 'guvenlik':
      return const Color(0xFF3E7BD9);

    case 'musteri_hizmetleri':
      return const Color(0xFF27A769);

    case 'kantar':
      return const Color(0xFFFF7A1A);

    case 'gumruk':
      return const Color(0xFF8155C7);

    default:
      return const Color(0xFF667085);
  }
}

IconData _birimIkonu(String tur) {
  switch (tur) {
    case 'isg':
      return Icons.health_and_safety;

    case 'itfaiye':
      return Icons.local_fire_department;

    case 'guvenlik':
      return Icons.shield;

    case 'musteri_hizmetleri':
      return Icons.phone;

    case 'kantar':
      return Icons.scale;

    case 'gumruk':
      return Icons.account_balance;

    default:
      return Icons.info;
  }
}