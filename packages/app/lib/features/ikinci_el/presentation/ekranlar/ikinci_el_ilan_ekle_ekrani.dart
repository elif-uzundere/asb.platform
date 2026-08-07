import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/ikinci_el_api.dart';
import '../providers/ikinci_el_provider.dart';

class IkinciElIlanEkleEkrani extends ConsumerStatefulWidget {
  const IkinciElIlanEkleEkrani({
    super.key,
  });

  @override
  ConsumerState<IkinciElIlanEkleEkrani> createState() {
    return _IkinciElIlanEkleEkraniDurumu();
  }
}

class _IkinciElIlanEkleEkraniDurumu
    extends ConsumerState<IkinciElIlanEkleEkrani> {
  final GlobalKey<FormState> _formAnahtari =
      GlobalKey<FormState>();

  final TextEditingController _baslikController =
      TextEditingController();

  final TextEditingController _aciklamaController =
      TextEditingController();

  final TextEditingController _fiyatController =
      TextEditingController();

  final TextEditingController _gorselUrlController =
      TextEditingController();

  String? _seciliKategori;
  String? _seciliDurum;

  bool _kaydediliyor = false;

  static const List<String> _kategoriler = [
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

  static const List<String> _durumlar = [
    'Sıfır',
    'Yeni gibi',
    'İyi durumda',
    'Kullanılmış',
    'Bakım gerekli',
  ];

  @override
  void dispose() {
    _baslikController.dispose();
    _aciklamaController.dispose();
    _fiyatController.dispose();
    _gorselUrlController.dispose();

    super.dispose();
  }

  void _geriDon() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/ikinci-el');
    }
  }

  Future<void> _ilaniKaydet() async {
    final formGecerli =
        _formAnahtari.currentState?.validate() ?? false;

    if (!formGecerli) {
      return;
    }

    final fiyat = double.tryParse(
      _fiyatController.text.trim(),
    );

    if (fiyat == null) {
      return;
    }

    setState(() {
      _kaydediliyor = true;
    });

    try {
      await ref.read(ikinciElApiProvider).ilanOlustur(
            baslik: _baslikController.text.trim(),
            aciklama: _aciklamaController.text.trim(),
            fiyat: fiyat,
            kategori: _seciliKategori!,
            urunDurumu: _seciliDurum!,
            fotografUrls: [
              _gorselUrlController.text.trim(),
            ],
          );

      ref.invalidate(
        ikinciElIlanlariProvider,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'İlan başarıyla oluşturuldu.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

      context.pop(true);
    } catch (hata) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              hata.toString(),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _kaydediliyor = false;
        });
      }
    }
  }

  String? _zorunluAlanKontrolu(
    String? deger,
    String mesaj,
  ) {
    if (deger == null || deger.trim().isEmpty) {
      return mesaj;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF7F8FC,
      ),
      appBar: AppBar(
        backgroundColor: const Color(
          0xFFF7F8FC,
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed:
              _kaydediliyor ? null : _geriDon,
          tooltip: 'Geri',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(
              0xFF0B315E,
            ),
          ),
        ),
        title: const Text(
          'İkinci El İlan Ekle',
          style: TextStyle(
            color: Color(
              0xFF0B315E,
            ),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Form(
        key: _formAnahtari,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            32,
          ),
          children: [
            const _BilgiKarti(),

            const SizedBox(
              height: 24,
            ),

            const _BolumBasligi(
              baslik: 'İlan Bilgileri',
            ),

            const SizedBox(
              height: 10,
            ),

            TextFormField(
              controller:
                  _baslikController,
              enabled:
                  !_kaydediliyor,
              textInputAction:
                  TextInputAction.next,
              decoration:
                  const InputDecoration(
                labelText:
                    'İlan başlığı',
                hintText:
                    'Örnek: CNC Torna Tezgâhı',
                prefixIcon: Icon(
                  Icons.title_rounded,
                ),
                border:
                    OutlineInputBorder(),
              ),
              validator: (deger) {
                return _zorunluAlanKontrolu(
                  deger,
                  'İlan başlığını yazmalısınız.',
                );
              },
            ),

            const SizedBox(
              height: 14,
            ),

            TextFormField(
              controller:
                  _aciklamaController,
              enabled:
                  !_kaydediliyor,
              minLines: 4,
              maxLines: 7,
              decoration:
                  const InputDecoration(
                labelText: 'Açıklama',
                hintText:
                    'Ürünün özelliklerini ve durumunu açıklayın.',
                alignLabelWithHint:
                    true,
                prefixIcon: Padding(
                  padding:
                      EdgeInsets.only(
                    bottom: 75,
                  ),
                  child: Icon(
                    Icons
                        .description_outlined,
                  ),
                ),
                border:
                    OutlineInputBorder(),
              ),
              validator: (deger) {
                return _zorunluAlanKontrolu(
                  deger,
                  'Ürün açıklamasını yazmalısınız.',
                );
              },
            ),

            const SizedBox(
              height: 14,
            ),

            TextFormField(
              controller:
                  _fiyatController,
              enabled:
                  !_kaydediliyor,
              keyboardType:
                  TextInputType.number,
              textInputAction:
                  TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter
                    .digitsOnly,
              ],
              decoration:
                  const InputDecoration(
                labelText: 'Fiyat',
                hintText: '450000',
                suffixText: 'TL',
                prefixIcon: Icon(
                  Icons
                      .payments_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              validator: (deger) {
                final hata =
                    _zorunluAlanKontrolu(
                  deger,
                  'Fiyatı yazmalısınız.',
                );

                if (hata != null) {
                  return hata;
                }

                final fiyat =
                    double.tryParse(
                  deger!,
                );

                if (fiyat == null ||
                    fiyat <= 0) {
                  return 'Geçerli bir fiyat yazmalısınız.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 14,
            ),

            DropdownButtonFormField<
                String>(
              initialValue:
                  _seciliKategori,
              decoration:
                  const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(
                  Icons
                      .category_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              hint: const Text(
                'Kategori seçin',
              ),
              items: _kategoriler
                  .map(
                    (kategori) =>
                        DropdownMenuItem<
                            String>(
                      value:
                          kategori,
                      child: Text(
                        kategori,
                      ),
                    ),
                  )
                  .toList(),
              onChanged:
                  _kaydediliyor
                      ? null
                      : (deger) {
                          setState(
                            () {
                              _seciliKategori =
                                  deger;
                            },
                          );
                        },
              validator: (deger) {
                if (deger == null) {
                  return 'Bir kategori seçmelisiniz.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 14,
            ),

            DropdownButtonFormField<
                String>(
              initialValue:
                  _seciliDurum,
              decoration:
                  const InputDecoration(
                labelText:
                    'Ürün durumu',
                prefixIcon: Icon(
                  Icons
                      .inventory_2_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              hint: const Text(
                'Ürün durumunu seçin',
              ),
              items: _durumlar
                  .map(
                    (durum) =>
                        DropdownMenuItem<
                            String>(
                      value: durum,
                      child: Text(
                        durum,
                      ),
                    ),
                  )
                  .toList(),
              onChanged:
                  _kaydediliyor
                      ? null
                      : (deger) {
                          setState(
                            () {
                              _seciliDurum =
                                  deger;
                            },
                          );
                        },
              validator: (deger) {
                if (deger == null) {
                  return 'Ürün durumunu seçmelisiniz.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 24,
            ),

            const _BolumBasligi(
              baslik: 'Görsel',
            ),

            const SizedBox(
              height: 10,
            ),

            TextFormField(
              controller:
                  _gorselUrlController,
              enabled:
                  !_kaydediliyor,
              keyboardType:
                  TextInputType.url,
              textInputAction:
                  TextInputAction.done,
              decoration:
                  const InputDecoration(
                labelText:
                    'Görsel bağlantısı',
                hintText:
                    'https://...',
                prefixIcon: Icon(
                  Icons.image_outlined,
                ),
                border:
                    OutlineInputBorder(),
              ),
              validator: (deger) {
                final hata =
                    _zorunluAlanKontrolu(
                  deger,
                  'Görsel bağlantısını yazmalısınız.',
                );

                if (hata != null) {
                  return hata;
                }

                final uri =
                    Uri.tryParse(
                  deger!,
                );

                if (uri == null ||
                    !uri.hasScheme ||
                    !uri.hasAuthority) {
                  return 'Geçerli bir görsel bağlantısı yazmalısınız.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 26,
            ),

            FilledButton.icon(
              onPressed:
                  _kaydediliyor
                      ? null
                      : _ilaniKaydet,
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF0B5EA8,
                ),
                minimumSize:
                    const Size
                        .fromHeight(
                  54,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),
              icon:
                  _kaydediliyor
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth:
                                2.4,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons
                              .add_rounded,
                        ),
              label: Text(
                _kaydediliyor
                    ? 'Kaydediliyor...'
                    : 'İlanı Kaydet',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BilgiKarti
    extends StatelessWidget {
  const _BilgiKarti();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        17,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFEEF5FC,
        ),
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              const Color(
            0xFFD6E5F5,
          ),
        ),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .info_outline_rounded,
            color: Color(
              0xFF0B5EA8,
            ),
            size: 26,
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child: Text(
              'Kategori elle yazılmaz. Sistemde bulunan kategoriler arasından seçim yapılır. Firma ve konum bilgisi sistem tarafından otomatik belirlenir.',
              style: TextStyle(
                color: Color(
                  0xFF344054,
                ),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BolumBasligi
    extends StatelessWidget {
  const _BolumBasligi({
    required this.baslik,
  });

  final String baslik;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Text(
      baslik,
      style:
          const TextStyle(
        color: Color(
          0xFF0B315E,
        ),
        fontSize: 17,
        fontWeight:
            FontWeight.w700,
      ),
    );
  }
}