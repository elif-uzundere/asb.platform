import 'package:file_picker/file_picker.dart';
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

  final TextEditingController _telefonController =
      TextEditingController();

  String? _seciliKategori;
  String? _seciliDurum;

  final List<PlatformFile> _seciliFotograflar = [];

  bool _kaydediliyor = false;

  static const _izinliUzantilar = ['jpg', 'jpeg', 'png', 'webp'];
  static const _maksimumBoyutBayt = 5 * 1024 * 1024;
  static const _maksimumFotografAdedi = 10;

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
    _telefonController.dispose();

    super.dispose();
  }

  Future<void> _fotografSec() async {
    final kalanKontenjan =
        _maksimumFotografAdedi - _seciliFotograflar.length;
    if (kalanKontenjan <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('En fazla $_maksimumFotografAdedi fotoğraf ekleyebilirsiniz.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }

    final sonuc = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _izinliUzantilar,
      allowMultiple: true,
      withData: true,
    );
    final dosyalar = sonuc?.files ?? const <PlatformFile>[];
    if (dosyalar.isEmpty) return;

    final gecerliDosyalar = <PlatformFile>[];
    for (final dosya in dosyalar) {
      if (dosya.size > _maksimumBoyutBayt) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('${dosya.name}: görsel en fazla 5 MB olabilir.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        continue;
      }
      gecerliDosyalar.add(dosya);
    }

    setState(() {
      _seciliFotograflar.addAll(
        gecerliDosyalar.take(kalanKontenjan),
      );
    });
  }

  void _fotografiKaldir(int index) {
    setState(() => _seciliFotograflar.removeAt(index));
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

    if (_seciliFotograflar.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('En az bir fotoğraf eklemelisiniz.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
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
            iletisimTelefonu: _telefonController.text.trim(),
            fotograflar: _seciliFotograflar
                .map(
                  (dosya) => IkinciElFotografi(
                    baytlar: dosya.bytes!,
                    dosyaAdi: dosya.name,
                  ),
                )
                .toList(),
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
              height: 14,
            ),

            TextFormField(
              controller: _telefonController,
              enabled: !_kaydediliyor,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'İletişim telefonu',
                hintText: '05XX XXX XX XX',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (deger) => _zorunluAlanKontrolu(
                deger,
                'İletişim telefonunu yazmalısınız.',
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            const _BolumBasligi(
              baslik: 'Fotoğraflar',
            ),

            const SizedBox(
              height: 10,
            ),

            _FotografSeciciIzgarasi(
              seciliFotograflar: _seciliFotograflar,
              devreDisi: _kaydediliyor,
              fotografEkle: _fotografSec,
              fotografKaldir: _fotografiKaldir,
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

/// "Sahibinden gibi" — seçili fotoğrafların küçük resim ızgarası + ekleme
/// kutusu. Gerçek dosya yükleme (Palet Tesisi'ndeki aynı desen), URL
/// yapıştırma YOK.
class _FotografSeciciIzgarasi extends StatelessWidget {
  const _FotografSeciciIzgarasi({
    required this.seciliFotograflar,
    required this.devreDisi,
    required this.fotografEkle,
    required this.fotografKaldir,
  });

  final List<PlatformFile> seciliFotograflar;
  final bool devreDisi;
  final VoidCallback fotografEkle;
  final void Function(int index) fotografKaldir;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (var i = 0; i < seciliFotograflar.length; i++)
          _FotografKutusu(
            dosya: seciliFotograflar[i],
            devreDisi: devreDisi,
            kaldir: () => fotografKaldir(i),
          ),
        InkWell(
          onTap: devreDisi ? null : fotografEkle,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD0D5DD)),
              color: const Color(0xFFF7F8FC),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: Color(0xFF667085), size: 22),
                SizedBox(height: 4),
                Text(
                  'Ekle',
                  style: TextStyle(fontSize: 11, color: Color(0xFF667085)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FotografKutusu extends StatelessWidget {
  const _FotografKutusu({
    required this.dosya,
    required this.devreDisi,
    required this.kaldir,
  });

  final PlatformFile dosya;
  final bool devreDisi;
  final VoidCallback kaldir;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 84,
            height: 84,
            child: dosya.bytes != null
                ? Image.memory(dosya.bytes!, fit: BoxFit.cover)
                : Container(
                    color: const Color(0xFFF0F2F5),
                    child: const Icon(Icons.image_outlined, color: Color(0xFF98A2B3)),
                  ),
          ),
        ),
        if (!devreDisi)
          Positioned(
            top: -6,
            right: -6,
            child: InkWell(
              onTap: kaldir,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFFD92D20),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
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