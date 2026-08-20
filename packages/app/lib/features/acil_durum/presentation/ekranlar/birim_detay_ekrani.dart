import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/acil_durum_birimi.dart';
import '../providers/acil_durum_provider.dart';

class BirimDetayEkrani
    extends ConsumerWidget {
  const BirimDetayEkrani({
    super.key,
    required this.birim,
  });

  final AcilDurumBirimi birim;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final detayAsync = ref.watch(
      acilDurumBirimiDetayProvider(
        birim.tur,
      ),
    );

    return detayAsync.when(
      loading: () {
        return Scaffold(
          backgroundColor:
              const Color(0xFFF7F8FA),
          appBar: _appBar(
            context,
            birim.ad,
          ),
          body: const Center(
            child:
                CircularProgressIndicator(),
          ),
        );
      },

      error: (hata, _) {
        return Scaffold(
          backgroundColor:
              const Color(0xFFF7F8FA),
          appBar: _appBar(
            context,
            birim.ad,
          ),
          body: Center(
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
                  const SizedBox(
                    height: 12,
                  ),
                  const Text(
                    'Bilgiler yüklenemedi.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  FilledButton(
                    onPressed: () {
                      ref.invalidate(
                        acilDurumBirimiDetayProvider(
                          birim.tur,
                        ),
                      );
                    },
                    child: const Text(
                      'Tekrar Dene',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },

      data: (guncelBirim) {
        return _DetayIcerigi(
          birim: guncelBirim,
        );
      },
    );
  }

  PreferredSizeWidget _appBar(
    BuildContext context,
    String baslik,
  ) {
    return AppBar(
      backgroundColor:
          const Color(0xFF153773),
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
      title: Text(
        baslik,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetayIcerigi
    extends StatelessWidget {
  const _DetayIcerigi({
    required this.birim,
  });

  final AcilDurumBirimi birim;

  @override
  Widget build(
    BuildContext context,
  ) {
    final renk =
        _birimRengi(birim.tur);

    final ikon =
        _birimIkonu(birim.tur);

    final itfaiyeMi = birim.tur == 'itfaiye';

    final telefonVar =
        birim.telefon != null &&
        birim.telefon!
            .trim()
            .isNotEmpty;

    final telefon2Var =
        birim.telefon2 != null &&
        birim.telefon2!
            .trim()
            .isNotEmpty;

    final epostaVar =
        birim.eposta != null &&
        birim.eposta!
            .trim()
            .isNotEmpty;

    final adresVar =
        birim.adres != null &&
        birim.adres!
            .trim()
            .isNotEmpty;

    final calismaSaatleriVar =
        birim.calismaSaatleri != null &&
        birim.calismaSaatleri!
            .trim()
            .isNotEmpty;

    final aciklamaVar =
        birim.aciklama != null &&
        birim.aciklama!
            .trim()
            .isNotEmpty;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF153773),
        foregroundColor:
            Colors.white,
        centerTitle: true,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons
                .arrow_back_ios_new_rounded,
            size: 19,
          ),
        ),

        title: Text(
          birim.ad,
          style: const TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),

      body: ListView(
        padding:
            const EdgeInsets.fromLTRB(
          18,
          24,
          18,
          32,
        ),
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration:
                    BoxDecoration(
                  color: renk,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ikon,
                  color: Colors.white,
                  size: 27,
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      birim.ad,
                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF111827,
                        ),
                        fontSize: 17,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      _detayAltBaslik(
                        birim.tur,
                      ),
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
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          Container(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              18,
              16,
              18,
            ),
            decoration:
                BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color:
                    const Color(
                  0xFFE7E9EE,
                ),
              ),
              boxShadow: const [
                BoxShadow(
                  color:
                      Color(
                    0x0A000000,
                  ),
                  blurRadius: 12,
                  offset:
                      Offset(0, 4),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'İletişim Bilgileri',
                  style: TextStyle(
                    color:
                        Color(
                      0xFF111827,
                    ),
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                // İtfaiye'de 112 EVRENSEL/sabit bir numara — veritabanından
                // gelmiyor, uygulamada sabit (bkz. dosya sonundaki not).
                // Birimin kendi doğrudan hattı (varsa) 112'nin altında,
                // nötr renkte ikinci bir bilgi satırı olarak gösterilir.
                if (itfaiyeMi) ...[
                  _BilgiSatiri(
                    ikon: Icons.phone_outlined,
                    ikonRengi: renk,
                    yazi: '112',
                    yaziRengi: renk,
                  ),
                  if (telefonVar) ...[
                    const SizedBox(height: 16),
                    _BilgiSatiri(
                      ikon: Icons.phone_outlined,
                      ikonRengi: const Color(0xFF172B4D),
                      yazi: birim.telefon!,
                      yaziRengi: const Color(0xFF172B4D),
                    ),
                  ],
                ] else ...[
                  if (telefonVar)
                    _BilgiSatiri(
                      ikon:
                          Icons.phone_outlined,
                      ikonRengi: renk,
                      yazi:
                          birim.telefon!,
                      yaziRengi: renk,
                    ),

                  if (telefonVar &&
                      telefon2Var)
                    const SizedBox(
                      height: 16,
                    ),

                  if (telefon2Var)
                    _BilgiSatiri(
                      ikon:
                          Icons.phone_outlined,
                      ikonRengi: renk,
                      yazi:
                          birim.telefon2!,
                      yaziRengi: renk,
                    ),
                ],

                if ((telefonVar || itfaiyeMi) &&
                    epostaVar)
                  const SizedBox(
                    height: 16,
                  ),

                if (epostaVar)
                  _BilgiSatiri(
                    ikon: Icons
                        .mail_outline_rounded,
                    ikonRengi:
                        const Color(
                      0xFF172B4D,
                    ),
                    yazi:
                        birim.eposta!,
                    yaziRengi:
                        const Color(
                      0xFF172B4D,
                    ),
                  ),

                if (!itfaiyeMi &&
                    !telefonVar &&
                    !epostaVar)
                  const Text(
                    'İletişim bilgisi henüz eklenmedi.',
                    style: TextStyle(
                      color:
                          Color(
                        0xFF667085,
                      ),
                      fontSize: 12,
                    ),
                  ),

                if (adresVar) ...[
                  const _Ayirici(),

                  const Text(
                    'Adres',
                    style: TextStyle(
                      color:
                          Color(
                        0xFF111827,
                      ),
                      fontSize: 13,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _BilgiSatiri(
                    ikon: Icons
                        .location_on_outlined,
                    ikonRengi:
                        const Color(
                      0xFF172B4D,
                    ),
                    yazi:
                        birim.adres!,
                    yaziRengi:
                        const Color(
                      0xFF25324A,
                    ),
                  ),
                ],

                if (calismaSaatleriVar)
                  ...[
                    const _Ayirici(),

                    const Text(
                      'Çalışma Saatleri',
                      style:
                          TextStyle(
                        color:
                            Color(
                          0xFF111827,
                        ),
                        fontSize: 13,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    _BilgiSatiri(
                      ikon: Icons
                          .schedule_outlined,
                      ikonRengi:
                          const Color(
                        0xFF172B4D,
                      ),
                      yazi: birim
                          .calismaSaatleri!,
                      yaziRengi:
                          const Color(
                        0xFF25324A,
                      ),
                    ),
                  ],

                if (aciklamaVar) ...[
                  const _Ayirici(),

                  const Text(
                    'Açıklama',
                    style: TextStyle(
                      color:
                          Color(
                        0xFF111827,
                      ),
                      fontSize: 13,
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    birim.aciklama!,
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF25324A,
                      ),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                ],

                // Mockup'ta İtfaiye için tek, vurgulu bir "Acil Ara (112)"
                // butonu var. Birimin kendi hattını arayan ayrı bir "Ara"
                // butonu yok, kafa karıştırmasın diye.
                if (itfaiyeMi) ...[
                  const SizedBox(
                    height: 26,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () => _telefonAra(context, '112'),
                      icon: const Icon(Icons.phone_rounded, size: 18),
                      label: const Text(
                        'Acil Ara (112)',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: renk,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ),
                ] else if (telefonVar ||
                    epostaVar) ...[
                  const SizedBox(
                    height: 26,
                  ),

                  Row(
                    children: [
                      if (telefonVar)
                        Expanded(
                          child:
                              SizedBox(
                            height: 46,
                            child:
                                FilledButton
                                    .icon(
                              onPressed:
                                  () {
                                _telefonAra(
                                  context,
                                  birim
                                      .telefon!,
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .phone_rounded,
                                size: 17,
                              ),
                              label:
                                  const Text(
                                'Ara',
                              ),
                              style:
                                  FilledButton
                                      .styleFrom(
                                backgroundColor:
                                    renk,
                                foregroundColor:
                                    Colors
                                        .white,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    7,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      if (telefonVar &&
                          epostaVar)
                        const SizedBox(
                          width: 12,
                        ),

                      if (epostaVar)
                        Expanded(
                          child:
                              SizedBox(
                            height: 46,
                            child:
                                OutlinedButton
                                    .icon(
                              onPressed:
                                  () {
                                _epostaGonder(
                                  context,
                                  birim
                                      .eposta!,
                                );
                              },
                              icon:
                                  const Icon(
                                Icons
                                    .mail_outline_rounded,
                                size: 17,
                              ),
                              label:
                                  const Text(
                                'E-posta',
                              ),
                              style:
                                  OutlinedButton
                                      .styleFrom(
                                foregroundColor:
                                    const Color(
                                  0xFF172B4D,
                                ),
                                side:
                                    const BorderSide(
                                  color:
                                      Color(
                                    0xFFAAB4C4,
                                  ),
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    7,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _telefonAra(
    BuildContext context,
    String telefon,
  ) async {
    final uri = Uri(
      scheme: 'tel',
      path: telefon,
    );

    final acildi =
        await launchUrl(uri);

    if (!acildi &&
        context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Telefon uygulaması açılamadı.',
          ),
        ),
      );
    }
  }

  Future<void> _epostaGonder(
    BuildContext context,
    String eposta,
  ) async {
    final uri = Uri(
      scheme: 'mailto',
      path: eposta,
    );

    final acildi =
        await launchUrl(uri);

    if (!acildi &&
        context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'E-posta uygulaması açılamadı.',
          ),
        ),
      );
    }
  }
}

class _BilgiSatiri
    extends StatelessWidget {
  const _BilgiSatiri({
    required this.ikon,
    required this.ikonRengi,
    required this.yazi,
    required this.yaziRengi,
  });

  final IconData ikon;
  final Color ikonRengi;
  final String yazi;
  final Color yaziRengi;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          ikon,
          size: 19,
          color: ikonRengi,
        ),

        const SizedBox(
          width: 14,
        ),

        Expanded(
          child: Text(
            yazi,
            style: TextStyle(
              color: yaziRengi,
              fontSize: 13,
              height: 1.4,
              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ),
      ],
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
        vertical: 17,
      ),
      child: Divider(
        height: 1,
        color:
            Color(0xFFE7E9EE),
      ),
    );
  }
}

String _detayAltBaslik(
  String tur,
) {
  switch (tur) {
    case 'isg':
      return 'İş Sağlığı ve Güvenliği';

    case 'itfaiye':
      return 'İtfaiye Acil Çağrı';

    case 'guvenlik':
      return 'Güvenlik Birimi';

    case 'musteri_hizmetleri':
      return 'ASB İletişim Merkezi';

    case 'kantar':
      return 'Kantar Birimi';

    case 'gumruk':
      return 'Gümrük Birimi';

    default:
      return '';
  }
}

Color _birimRengi(
  String tur,
) {
  switch (tur) {
    case 'isg':
      return const Color(
        0xFF2DA968,
      );

    case 'itfaiye':
      return const Color(
        0xFFF04444,
      );

    case 'guvenlik':
      return const Color(
        0xFF3E7BD9,
      );

    case 'musteri_hizmetleri':
      return const Color(
        0xFF27A769,
      );

    case 'kantar':
      return const Color(
        0xFFFF7A1A,
      );

    case 'gumruk':
      return const Color(
        0xFF8155C7,
      );

    default:
      return const Color(
        0xFF667085,
      );
  }
}

IconData _birimIkonu(
  String tur,
) {
  switch (tur) {
    case 'isg':
      return Icons
          .health_and_safety;

    case 'itfaiye':
      return Icons
          .local_fire_department;

    case 'guvenlik':
      return Icons.shield;

    case 'musteri_hizmetleri':
      return Icons.phone;

    case 'kantar':
      return Icons.scale;

    case 'gumruk':
      return Icons
          .account_balance;

    default:
      return Icons.info;
  }
}