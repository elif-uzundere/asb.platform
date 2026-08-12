import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/palet.dart';
import '../providers/palet_tesisi_provider.dart';

class PaletTesisiEkrani extends ConsumerWidget {
  const PaletTesisiEkrani({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final tesisBilgisiAsync =
        ref.watch(paletTesisiBilgisiProvider);

    final paletlerAsync =
        ref.watch(paletlerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: const Color(0xFF153773),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

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
            size: 19,
          ),
        ),

        title: const Text(
          'Palet Tesisi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            paletTesisiBilgisiProvider,
          );

          ref.invalidate(
            paletlerProvider,
          );
        },

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
            const _BolumBasligi(
              ikon: Icons.factory_outlined,
              baslik:
                  'Palet Tesisi Bilgileri',
            ),

            const SizedBox(height: 14),

            tesisBilgisiAsync.when(
              loading: () {
                return const _YukleniyorKarti();
              },

              error: (hata, _) {
                return const _HataKarti(
                  mesaj:
                      'Palet tesisi bilgileri yüklenemedi.',
                );
              },

              data: (bilgi) {
                if (bilgi == null) {
                  return const _BosBilgiKarti();
                }

                return _TesisBilgisiKarti(
                  aciklama:
                      bilgi.aciklama,
                  telefon:
                      bilgi.telefon,
                  eposta:
                      bilgi.eposta,
                  adres:
                      bilgi.adres,
                  calismaSaatleri:
                      bilgi.calismaSaatleri,
                );
              },
            ),

            const SizedBox(height: 28),

            paletlerAsync.when(
              loading: () {
                return const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _BolumBasligi(
                      ikon: Icons
                          .view_module_outlined,
                      baslik:
                          'Ürettiğimiz Paletler',
                    ),

                    SizedBox(height: 14),

                    _YukleniyorKarti(),
                  ],
                );
              },

              error: (hata, _) {
                return const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _BolumBasligi(
                      ikon: Icons
                          .view_module_outlined,
                      baslik:
                          'Ürettiğimiz Paletler',
                    ),

                    SizedBox(height: 14),

                    _HataKarti(
                      mesaj:
                          'Paletler yüklenemedi.',
                    ),
                  ],
                );
              },

              data: (paletler) {
                return Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const _BolumBasligi(
                      ikon: Icons
                          .view_module_outlined,
                      baslik:
                          'Ürettiğimiz Paletler',
                    ),

                    const SizedBox(height: 6),

                    Text(
                      paletler.isEmpty
                          ? 'Henüz palet bilgisi eklenmedi.'
                          : 'Tesisimizde toplam ${paletler.length} farklı palet üretilmektedir.',
                      style: const TextStyle(
                        color:
                            Color(0xFF667085),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (paletler.isEmpty)
                      const _BosPaletKarti()
                    else
                      _PaletIzgarasi(
                        paletler:
                            paletler,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BolumBasligi
    extends StatelessWidget {
  const _BolumBasligi({
    required this.ikon,
    required this.baslik,
  });

  final IconData ikon;
  final String baslik;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration:
              const BoxDecoration(
            color: Color(0xFF2F65C8),
            shape: BoxShape.circle,
          ),
          child: Icon(
            ikon,
            color: Colors.white,
            size: 22,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            baslik,
            style: const TextStyle(
              color: Color(0xFF153773),
              fontSize: 18,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _TesisBilgisiKarti
    extends StatelessWidget {
  const _TesisBilgisiKarti({
    required this.aciklama,
    required this.telefon,
    required this.eposta,
    required this.adres,
    required this.calismaSaatleri,
  });

  final String? aciklama;
  final String? telefon;
  final String? eposta;
  final String? adres;
  final String? calismaSaatleri;

  bool _varMi(String? deger) {
    return deger != null &&
        deger.trim().isNotEmpty;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final herhangiBirBilgiVar =
        _varMi(aciklama) ||
        _varMi(telefon) ||
        _varMi(eposta) ||
        _varMi(adres) ||
        _varMi(calismaSaatleri);

    if (!herhangiBirBilgiVar) {
      return const _BosBilgiKarti();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _kartDekorasyonu(),
      child: Column(
        children: [
          if (_varMi(aciklama))
            _BilgiSatiri(
              ikon:
                  Icons.info_outline_rounded,
              baslik: 'Tesis Hakkında',
              deger: aciklama!,
            ),

          if (_varMi(aciklama) &&
              (_varMi(telefon) ||
                  _varMi(eposta) ||
                  _varMi(adres) ||
                  _varMi(
                    calismaSaatleri,
                  )))
            const _Ayirici(),

          if (_varMi(telefon))
            _BilgiSatiri(
              ikon:
                  Icons.phone_outlined,
              baslik: 'Telefon',
              deger: telefon!,
            ),

          if (_varMi(telefon) &&
              (_varMi(eposta) ||
                  _varMi(adres) ||
                  _varMi(
                    calismaSaatleri,
                  )))
            const _Ayirici(),

          if (_varMi(eposta))
            _BilgiSatiri(
              ikon:
                  Icons.mail_outline_rounded,
              baslik: 'E-posta',
              deger: eposta!,
            ),

          if (_varMi(eposta) &&
              (_varMi(adres) ||
                  _varMi(
                    calismaSaatleri,
                  )))
            const _Ayirici(),

          if (_varMi(adres))
            _BilgiSatiri(
              ikon: Icons
                  .location_on_outlined,
              baslik: 'Adres',
              deger: adres!,
            ),

          if (_varMi(adres) &&
              _varMi(calismaSaatleri))
            const _Ayirici(),

          if (_varMi(calismaSaatleri))
            _BilgiSatiri(
              ikon:
                  Icons.schedule_outlined,
              baslik:
                  'Çalışma Saatleri',
              deger:
                  calismaSaatleri!,
            ),
        ],
      ),
    );
  }
}

class _BilgiSatiri
    extends StatelessWidget {
  const _BilgiSatiri({
    required this.ikon,
    required this.baslik,
    required this.deger,
  });

  final IconData ikon;
  final String baslik;
  final String deger;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration:
              const BoxDecoration(
            color: Color(0xFFF0F4FC),
            shape: BoxShape.circle,
          ),
          child: Icon(
            ikon,
            color: Color(0xFF2F65C8),
            size: 20,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                baslik,
                style:
                    const TextStyle(
                  color:
                      Color(0xFF667085),
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                deger,
                style:
                    const TextStyle(
                  color:
                      Color(0xFF111827),
                  fontSize: 13,
                  height: 1.4,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaletIzgarasi
    extends StatelessWidget {
  const _PaletIzgarasi({
    required this.paletler,
  });

  final List<Palet> paletler;

  @override
  Widget build(
    BuildContext context,
  ) {
    return LayoutBuilder(
      builder: (
        context,
        constraints,
      ) {
        final genislik =
            constraints.maxWidth;

        final tekKolon =
            genislik < 500;

        if (tekKolon) {
          return Column(
            children: paletler
                .map(
                  (palet) => Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      bottom: 12,
                    ),
                    child: _PaletKarti(
                      palet: palet,
                    ),
                  ),
                )
                .toList(),
          );
        }

        return GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),

          itemCount: paletler.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),

          itemBuilder: (
            context,
            index,
          ) {
            return _PaletKarti(
              palet:
                  paletler[index],
            );
          },
        );
      },
    );
  }
}

class _PaletKarti
    extends StatelessWidget {
  const _PaletKarti({
    required this.palet,
  });

  final Palet palet;

  bool _varMi(String? deger) {
    return deger != null &&
        deger.trim().isNotEmpty;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      decoration: _kartDekorasyonu(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _PaletGorseli(
              gorselUrl:
                  palet.gorselUrl,
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  palet.ad,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF153773),
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                if (_varMi(
                  palet.olcu,
                )) ...[
                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'Ölçü: ${palet.olcu}',
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF667085,
                      ),
                      fontSize: 12,
                    ),
                  ),
                ],

                if (_varMi(
                  palet.aciklama,
                )) ...[
                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    palet.aciklama!,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF344054,
                      ),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletGorseli
    extends StatelessWidget {
  const _PaletGorseli({
    required this.gorselUrl,
  });

  final String? gorselUrl;

  @override
  Widget build(
    BuildContext context,
  ) {
    final urlVar =
        gorselUrl != null &&
        gorselUrl!.trim().isNotEmpty;

    if (!urlVar) {
      return const _GorselYok();
    }

    return Image.network(
      gorselUrl!,
      width: double.infinity,
      fit: BoxFit.cover,

      errorBuilder: (
        context,
        hata,
        stackTrace,
      ) {
        return const _GorselYok();
      },

      loadingBuilder: (
        context,
        child,
        loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }

        return const Center(
          child:
              CircularProgressIndicator(),
        );
      },
    );
  }
}

class _GorselYok
    extends StatelessWidget {
  const _GorselYok();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      color: const Color(0xFFF0F2F5),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFF98A2B3),
          size: 40,
        ),
      ),
    );
  }
}

class _Ayirici
    extends StatelessWidget {
  const _Ayirici();

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Divider(
        height: 1,
        color:
            Color(0xFFE7E9EE),
      ),
    );
  }
}

class _YukleniyorKarti
    extends StatelessWidget {
  const _YukleniyorKarti();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      height: 110,
      decoration:
          _kartDekorasyonu(),
      child: const Center(
        child:
            CircularProgressIndicator(),
      ),
    );
  }
}

class _HataKarti
    extends StatelessWidget {
  const _HataKarti({
    required this.mesaj,
  });

  final String mesaj;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          _kartDekorasyonu(),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              mesaj,
              style:
                  const TextStyle(
                color:
                    Color(0xFF667085),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BosBilgiKarti
    extends StatelessWidget {
  const _BosBilgiKarti();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          _kartDekorasyonu(),
      child: const Text(
        'Palet tesisi bilgileri henüz eklenmedi.',
        style: TextStyle(
          color: Color(0xFF667085),
          fontSize: 12,
        ),
      ),
    );
  }
}

class _BosPaletKarti
    extends StatelessWidget {
  const _BosPaletKarti();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration:
          _kartDekorasyonu(),
      child: const Center(
        child: Text(
          'Henüz palet eklenmedi.',
          style: TextStyle(
            color: Color(0xFF667085),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

BoxDecoration _kartDekorasyonu() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius:
        BorderRadius.circular(12),
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
  );
}