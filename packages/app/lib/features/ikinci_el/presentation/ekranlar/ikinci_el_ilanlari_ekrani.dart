import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/auth_modelleri.dart';
import '../../../auth/presentation/durum/auth_durumu.dart';
import '../../domain/ikinci_el_ilan.dart';
import '../providers/ikinci_el_provider.dart';

class IkinciElIlanlariEkrani extends ConsumerStatefulWidget {
  const IkinciElIlanlariEkrani({
    super.key,
  });

  @override
  ConsumerState<IkinciElIlanlariEkrani> createState() {
    return _IkinciElIlanlariEkraniDurumu();
  }
}

class _IkinciElIlanlariEkraniDurumu
    extends ConsumerState<IkinciElIlanlariEkrani> {
  final TextEditingController _aramaController =
      TextEditingController();

  final Set<String> _seciliKategoriler = <String>{};

  String _aramaMetni = '';
  String _siralama = 'En Yeni';

  double? _seciliEnDusukFiyat;
  double? _seciliEnYuksekFiyat;

  static const List<String> _tumKategoriler = [
    'Makine',
    'Yedek Parça',
    'Ekipman',
    'Ofis',
    'Elektronik',
    'Depo',
    'Mobilya',
    'Fazla Stok',
    'Araç',
    'İş Makinesi',
    'Diğer',
  ];

  static const List<String> _hizliKategoriler = [
    'Makine',
    'Yedek Parça',
    'Ekipman',
  ];

  final NumberFormat _paraFormati = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  void _geriDon() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  double _sistemEnDusukFiyatiBul(
    List<IkinciElIlan> ilanlar,
  ) {
    if (ilanlar.isEmpty) {
      return 0;
    }

    return ilanlar
        .map((ilan) => ilan.fiyat)
        .reduce((a, b) => a < b ? a : b);
  }

  double _sistemEnYuksekFiyatiBul(
    List<IkinciElIlan> ilanlar,
  ) {
    if (ilanlar.isEmpty) {
      return 0;
    }

    return ilanlar
        .map((ilan) => ilan.fiyat)
        .reduce((a, b) => a > b ? a : b);
  }

  List<IkinciElIlan> _ilanlariFiltrele(
    List<IkinciElIlan> tumIlanlar,
  ) {
    final arama = _aramaMetni.trim().toLowerCase();

    final sonuc = tumIlanlar.where((ilan) {
      final aramaUygun =
          arama.isEmpty ||
          ilan.baslik.toLowerCase().contains(arama) ||
          ilan.aciklama.toLowerCase().contains(arama) ||
          ilan.firmaAdi.toLowerCase().contains(arama);

      final kategoriUygun =
          _seciliKategoriler.isEmpty ||
          _seciliKategoriler.contains(ilan.kategori);

      final fiyatUygun =
          (_seciliEnDusukFiyat == null ||
              ilan.fiyat >= _seciliEnDusukFiyat!) &&
          (_seciliEnYuksekFiyat == null ||
              ilan.fiyat <= _seciliEnYuksekFiyat!);

      return aramaUygun &&
          kategoriUygun &&
          fiyatUygun;
    }).toList();

    switch (_siralama) {
      case 'En Eski':
        sonuc.sort(
          (a, b) => a.olusturulmaTarihi.compareTo(
            b.olusturulmaTarihi,
          ),
        );
        break;

      case 'Fiyat Artan':
        sonuc.sort(
          (a, b) => a.fiyat.compareTo(b.fiyat),
        );
        break;

      case 'Fiyat Azalan':
        sonuc.sort(
          (a, b) => b.fiyat.compareTo(a.fiyat),
        );
        break;

      case 'En Yeni':
      default:
        sonuc.sort(
          (a, b) => b.olusturulmaTarihi.compareTo(
            a.olusturulmaTarihi,
          ),
        );
    }

    return sonuc;
  }

  void _hizliKategoriSec(
    String kategori,
  ) {
    setState(() {
      if (_seciliKategoriler.contains(kategori)) {
        _seciliKategoriler.remove(kategori);
      } else {
        _seciliKategoriler.add(kategori);
      }
    });
  }

  Future<void> _tumKategorileriGoster() async {
    final geciciSecimler =
        Set<String>.from(_seciliKategoriler);

    final sonuc = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Container(
              height:
                  MediaQuery.sizeOf(context).height * 0.72,
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(26),
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0D5DD),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Kategoriler',
                    style: TextStyle(
                      color: Color(0xFF0B315E),
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Bir veya birden fazla kategori seçebilirsiniz.',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _tumKategoriler.length,
                      separatorBuilder: (context, index) {
                        return const Divider(
                          height: 1,
                          color: Color(0xFFEAECF0),
                        );
                      },
                      itemBuilder: (context, index) {
                        final kategori =
                            _tumKategoriler[index];

                        final secili =
                            geciciSecimler.contains(
                          kategori,
                        );

                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: secili,
                          activeColor:
                              const Color(0xFF0B5EA8),
                          controlAffinity:
                              ListTileControlAffinity
                                  .trailing,
                          title: Text(
                            kategori,
                            style: const TextStyle(
                              color: Color(0xFF0B315E),
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          onChanged: (deger) {
                            modalSetState(() {
                              if (deger == true) {
                                geciciSecimler.add(
                                  kategori,
                                );
                              } else {
                                geciciSecimler.remove(
                                  kategori,
                                );
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            modalSetState(() {
                              geciciSecimler.clear();
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize:
                                const Size.fromHeight(50),
                          ),
                          child: const Text('Temizle'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(
                              bottomSheetContext,
                            ).pop(geciciSecimler);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF0B5EA8),
                            minimumSize:
                                const Size.fromHeight(50),
                          ),
                          child: const Text('Uygula'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (sonuc == null) {
      return;
    }

    setState(() {
      _seciliKategoriler
        ..clear()
        ..addAll(sonuc);
    });
  }

  Future<void> _filtreleriGoster(
    List<IkinciElIlan> tumIlanlar,
  ) async {
    if (tumIlanlar.isEmpty) {
      return;
    }

    final sistemEnDusuk =
        _sistemEnDusukFiyatiBul(tumIlanlar);

    final sistemEnYuksek =
        _sistemEnYuksekFiyatiBul(tumIlanlar);

    double geciciEnDusuk =
        _seciliEnDusukFiyat ?? sistemEnDusuk;

    double geciciEnYuksek =
        _seciliEnYuksekFiyat ?? sistemEnYuksek;

    final enDusukController = TextEditingController(
      text: geciciEnDusuk.round().toString(),
    );

    final enYuksekController = TextEditingController(
      text: geciciEnYuksek.round().toString(),
    );

    final sonuc =
        await showModalBottomSheet<_FiyatSonucu>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            void yazilanFiyatlariUygula() {
              final yazilanEnDusuk = double.tryParse(
                enDusukController.text
                    .replaceAll('.', '')
                    .replaceAll(',', ''),
              );

              final yazilanEnYuksek = double.tryParse(
                enYuksekController.text
                    .replaceAll('.', '')
                    .replaceAll(',', ''),
              );

              if (yazilanEnDusuk == null ||
                  yazilanEnYuksek == null) {
                return;
              }

              final sinirliEnDusuk =
                  yazilanEnDusuk.clamp(
                sistemEnDusuk,
                sistemEnYuksek,
              );

              final sinirliEnYuksek =
                  yazilanEnYuksek.clamp(
                sistemEnDusuk,
                sistemEnYuksek,
              );

              if (sinirliEnDusuk > sinirliEnYuksek) {
                return;
              }

              modalSetState(() {
                geciciEnDusuk =
                    sinirliEnDusuk.toDouble();

                geciciEnYuksek =
                    sinirliEnYuksek.toDouble();
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.viewInsetsOf(context)
                        .bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  28,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFD0D5DD),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Filtrele',
                      style: TextStyle(
                        color: Color(0xFF0B315E),
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sistemdeki fiyat aralığı: '
                      '${_paraFormati.format(sistemEnDusuk)} – '
                      '${_paraFormati.format(sistemEnYuksek)}',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Fiyat Aralığı',
                      style: TextStyle(
                        color: Color(0xFF0B315E),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller:
                                enDusukController,
                            keyboardType:
                                TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly,
                            ],
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'En düşük fiyat',
                              suffixText: 'TL',
                              border:
                                  OutlineInputBorder(),
                            ),
                            onChanged: (deger) {
                              yazilanFiyatlariUygula();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller:
                                enYuksekController,
                            keyboardType:
                                TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly,
                            ],
                            decoration:
                                const InputDecoration(
                              labelText:
                                  'En yüksek fiyat',
                              suffixText: 'TL',
                              border:
                                  OutlineInputBorder(),
                            ),
                            onChanged: (deger) {
                              yazilanFiyatlariUygula();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (sistemEnDusuk <
                        sistemEnYuksek)
                      RangeSlider(
                        min: sistemEnDusuk,
                        max: sistemEnYuksek,
                        values: RangeValues(
                          geciciEnDusuk,
                          geciciEnYuksek,
                        ),
                        labels: RangeLabels(
                          _paraFormati.format(
                            geciciEnDusuk,
                          ),
                          _paraFormati.format(
                            geciciEnYuksek,
                          ),
                        ),
                        activeColor:
                            const Color(0xFF0B5EA8),
                        onChanged: (deger) {
                          modalSetState(() {
                            geciciEnDusuk =
                                deger.start;

                            geciciEnYuksek =
                                deger.end;

                            enDusukController.text =
                                deger.start
                                    .round()
                                    .toString();

                            enYuksekController.text =
                                deger.end
                                    .round()
                                    .toString();
                          });
                        },
                      ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _paraFormati.format(
                            geciciEnDusuk,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF475467),
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        Text(
                          _paraFormati.format(
                            geciciEnYuksek,
                          ),
                          style: const TextStyle(
                            color: Color(0xFF475467),
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(
                                bottomSheetContext,
                              ).pop(
                                const _FiyatSonucu(
                                  temizlendi: true,
                                ),
                              );
                            },
                            style:
                                OutlinedButton.styleFrom(
                              minimumSize:
                                  const Size.fromHeight(
                                50,
                              ),
                            ),
                            child: const Text('Temizle'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (geciciEnDusuk >
                                  geciciEnYuksek) {
                                return;
                              }

                              Navigator.of(
                                bottomSheetContext,
                              ).pop(
                                _FiyatSonucu(
                                  enDusuk:
                                      geciciEnDusuk,
                                  enYuksek:
                                      geciciEnYuksek,
                                ),
                              );
                            },
                            style:
                                FilledButton.styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFF0B5EA8,
                              ),
                              minimumSize:
                                  const Size.fromHeight(
                                50,
                              ),
                            ),
                            child: const Text('Uygula'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    enDusukController.dispose();
    enYuksekController.dispose();

    if (sonuc == null) {
      return;
    }

    setState(() {
      if (sonuc.temizlendi) {
        _seciliEnDusukFiyat = null;
        _seciliEnYuksekFiyat = null;
      } else {
        _seciliEnDusukFiyat = sonuc.enDusuk;
        _seciliEnYuksekFiyat = sonuc.enYuksek;
      }
    });
  }

  Future<void> _siralamaSec() async {
    final sonuc = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        const secenekler = [
          'En Yeni',
          'En Eski',
          'Fiyat Artan',
          'Fiyat Azalan',
        ];

        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D5DD),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Sırala',
                style: TextStyle(
                  color: Color(0xFF0B315E),
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...secenekler.map((secenek) {
                return RadioListTile<String>(
                  contentPadding: EdgeInsets.zero,
                  value: secenek,
                  groupValue: _siralama,
                  activeColor:
                      const Color(0xFF0B5EA8),
                  title: Text(secenek),
                  onChanged: (deger) {
                    Navigator.of(
                      bottomSheetContext,
                    ).pop(deger);
                  },
                );
              }),
            ],
          ),
        );
      },
    );

    if (sonuc == null) {
      return;
    }

    setState(() {
      _siralama = sonuc;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authDurumu = ref.watch(authProvider);
    final kullanici = authDurumu.kullanici;

    final ilanEkleyebilir =
        kullanici?.rol == KullaniciRolu.admin ||
        kullanici?.rol == KullaniciRolu.firmaYetkilisi;

    final ilanlarAsync =
        ref.watch(ikinciElIlanlariProvider);

    final favoriIdleri =
        ref.watch(favoriIlanlarProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _geriDon,
          tooltip: 'Geri',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF0B315E),
          ),
        ),
        title: const Text(
          'İkinci El İlanlar',
          style: TextStyle(
            color: Color(0xFF0B315E),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButton: ilanEkleyebilir
          ? FloatingActionButton.extended(
              onPressed: () async {
                await context.push('/ikinci-el/ilan-ekle');

                if (mounted) {
                  ref.invalidate(
                    ikinciElIlanlariProvider,
                  );
                }
              },
              backgroundColor: const Color(0xFF0B5EA8),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('İlan Ekle'),
            )
          : null,
      body: ilanlarAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (hata, stackTrace) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 54,
                    color: Color(0xFFB42318),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'İlanlar yüklenemedi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0B315E),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hata.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(
                        ikinciElIlanlariProvider,
                      );
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text(
                      'Tekrar Dene',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        data: (tumIlanlar) {
          final ilanlar =
              _ilanlariFiltrele(tumIlanlar);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  0,
                ),
                child: TextField(
                  controller: _aramaController,
                  onChanged: (deger) {
                    setState(() {
                      _aramaMetni = deger;
                    });
                  },
                  decoration: InputDecoration(
                    hintText:
                        'Ürün, marka veya firma ara...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                    ),
                    suffixIcon:
                        _aramaMetni.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _aramaController.clear();

                                  setState(() {
                                    _aramaMetni = '';
                                  });
                                },
                                icon: const Icon(
                                  Icons.close_rounded,
                                ),
                              ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(0xFFD0D5DD),
                      ),
                    ),
                    enabledBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(
                        color:
                            Color(0xFFD0D5DD),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 42,
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  scrollDirection:
                      Axis.horizontal,
                  children: [
                    _KategoriButonu(
                      metin: 'Tümü',
                      secili:
                          _seciliKategoriler.isEmpty,
                      onTap: () {
                        setState(() {
                          _seciliKategoriler
                              .clear();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ..._hizliKategoriler.map(
                      (kategori) {
                        return Padding(
                          padding:
                              const EdgeInsets.only(
                            right: 8,
                          ),
                          child:
                              _KategoriButonu(
                            metin: kategori,
                            secili:
                                _seciliKategoriler
                                    .contains(
                              kategori,
                            ),
                            onTap: () {
                              _hizliKategoriSec(
                                kategori,
                              );
                            },
                          ),
                        );
                      },
                    ),
                    _KategoriOkButonu(
                      seciliKategoriSayisi:
                          _seciliKategoriler.length,
                      onTap:
                          _tumKategorileriGoster,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        _filtreleriGoster(
                          tumIlanlar,
                        );
                      },
                      icon: const Icon(
                        Icons.tune_rounded,
                        size: 19,
                      ),
                      label:
                          const Text('Filtrele'),
                    ),
                    if (_seciliEnDusukFiyat !=
                            null ||
                        _seciliEnYuksekFiyat !=
                            null) ...[
                      const SizedBox(width: 7),
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color:
                            Color(0xFF0B5EA8),
                      ),
                    ],
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _siralamaSec,
                      label: Text(_siralama),
                      icon: const Icon(
                        Icons
                            .keyboard_arrow_down_rounded,
                      ),
                      iconAlignment:
                          IconAlignment.end,
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  16,
                  6,
                  16,
                  10,
                ),
                child: Row(
                  children: [
                    const Text(
                      'İlanlar',
                      style: TextStyle(
                        color:
                            Color(0xFF0B315E),
                        fontSize: 18,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${ilanlar.length} ilan',
                      style: const TextStyle(
                        color:
                            Color(0xFF667085),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ilanlar.isEmpty
                    ? const _BosIlanGorunumu()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await ref.refresh(
                            ikinciElIlanlariProvider
                                .future,
                          );
                        },
                        child:
                            ListView.separated(
                          padding:
                              const EdgeInsets
                                  .fromLTRB(
                            16,
                            0,
                            16,
                            100,
                          ),
                          itemCount:
                              ilanlar.length,
                          separatorBuilder:
                              (context,
                                  index) {
                            return const SizedBox(
                              height: 12,
                            );
                          },
                          itemBuilder:
                              (context,
                                  index) {
                            final ilan =
                                ilanlar[index];

                            return _IlanKarti(
                              ilan: ilan,
                              favoride:
                                  favoriIdleri
                                      .contains(
                                ilan.id,
                              ),
                              paraFormati:
                                  _paraFormati,
                              onFavoriTiklandi:
                                  () {
                                ref
                                    .read(
                                      favoriIlanlarProvider
                                          .notifier,
                                    )
                                    .favoriDegistir(
                                      ilan.id,
                                    );
                              },
                              onTap: () {
                                ScaffoldMessenger
                                    .of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(
                                        '${ilan.baslik} detay sayfası daha sonra bağlanacak.',
                                      ),
                                      behavior:
                                          SnackBarBehavior
                                              .floating,
                                    ),
                                  );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KategoriButonu extends StatelessWidget {
  const _KategoriButonu({
    required this.metin,
    required this.secili,
    required this.onTap,
  });

  final String metin;
  final bool secili;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: secili
          ? const Color(0xFF0B5EA8)
          : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 17,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: secili
                  ? const Color(0xFF0B5EA8)
                  : const Color(0xFFD0D5DD),
            ),
          ),
          child: Text(
            metin,
            style: TextStyle(
              color: secili
                  ? Colors.white
                  : const Color(0xFF344054),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _KategoriOkButonu extends StatelessWidget {
  const _KategoriOkButonu({
    required this.seciliKategoriSayisi,
    required this.onTap,
  });

  final int seciliKategoriSayisi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 46,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFD0D5DD),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (seciliKategoriSayisi > 0) ...[
                Text(
                  '$seciliKategoriSayisi',
                  style: const TextStyle(
                    color: Color(0xFF0B5EA8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 3),
              ],
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Color(0xFF0B315E),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IlanKarti extends StatelessWidget {
  const _IlanKarti({
    required this.ilan,
    required this.favoride,
    required this.paraFormati,
    required this.onFavoriTiklandi,
    required this.onTap,
  });

  final IkinciElIlan ilan;
  final bool favoride;
  final NumberFormat paraFormati;
  final VoidCallback onFavoriTiklandi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFEAECF0),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(14),
                child: Image.network(
                  ilan.gorselUrl,
                  width: 112,
                  height: 112,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      width: 112,
                      height: 112,
                      color:
                          const Color(0xFFEEF4FA),
                      child: const Icon(
                        Icons
                            .image_not_supported_outlined,
                        color: Color(0xFF667085),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            ilan.baslik,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:
                                  Color(0xFF0B315E),
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        IconButton(
                          onPressed:
                              onFavoriTiklandi,
                          visualDensity:
                              VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints:
                              const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: Icon(
                            favoride
                                ? Icons
                                    .favorite_rounded
                                : Icons
                                    .favorite_border_rounded,
                            color: favoride
                                ? const Color(
                                    0xFFE11D48,
                                  )
                                : const Color(
                                    0xFF667085,
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paraFormati.format(
                        ilan.fiyat,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF0B5EA8),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      ilan.durum,
                      style: const TextStyle(
                        color: Color(0xFF475467),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ilan.firmaAdi,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BosIlanGorunumu extends StatelessWidget {
  const _BosIlanGorunumu();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 58,
              color: Color(0xFF98A2B3),
            ),
            SizedBox(height: 14),
            Text(
              'Bu kriterlere uygun ilan bulunamadı.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF475467),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiyatSonucu {
  const _FiyatSonucu({
    this.enDusuk,
    this.enYuksek,
    this.temizlendi = false,
  });

  final double? enDusuk;
  final double? enYuksek;
  final bool temizlendi;
}