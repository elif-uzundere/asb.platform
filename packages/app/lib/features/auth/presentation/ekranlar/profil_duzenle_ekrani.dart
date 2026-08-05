import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';
import '../durum/auth_durumu.dart';

class ProfilDuzenleEkrani
    extends ConsumerStatefulWidget {
  const ProfilDuzenleEkrani({
    super.key,
  });

  @override
  ConsumerState<ProfilDuzenleEkrani> createState() {
    return _ProfilDuzenleEkraniDurumu();
  }
}

class _ProfilDuzenleEkraniDurumu
    extends ConsumerState<ProfilDuzenleEkrani> {
  final _formAnahtari = GlobalKey<FormState>();

  late final TextEditingController _ad;
  late final TextEditingController _soyad;
  late final TextEditingController _email;
  late final TextEditingController _telefon;

  late String _ilkAd;
  late String _ilkSoyad;
  late String _ilkEmail;
  late String _ilkTelefon;

  bool _kaydediliyor = false;

  @override
  void initState() {
    super.initState();

    final kullanici =
        ref.read(authProvider).kullanici;

    _ilkAd = kullanici?.ad ?? '';
    _ilkSoyad = kullanici?.soyad ?? '';
    _ilkEmail = kullanici?.email ?? '';
    _ilkTelefon = kullanici?.telefon ?? '';

    _ad = TextEditingController(
      text: _ilkAd,
    );

    _soyad = TextEditingController(
      text: _ilkSoyad,
    );

    _email = TextEditingController(
      text: _ilkEmail,
    );

    _telefon = TextEditingController(
      text: _ilkTelefon,
    );

    _ad.addListener(_yenile);
    _soyad.addListener(_yenile);
    _email.addListener(_yenile);
    _telefon.addListener(_yenile);
  }

  @override
  void dispose() {
    _ad.removeListener(_yenile);
    _soyad.removeListener(_yenile);
    _email.removeListener(_yenile);
    _telefon.removeListener(_yenile);

    _ad.dispose();
    _soyad.dispose();
    _email.dispose();
    _telefon.dispose();

    super.dispose();
  }

  void _yenile() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _degisiklikVar {
    return _ad.text.trim() != _ilkAd.trim() ||
        _soyad.text.trim() != _ilkSoyad.trim() ||
        _email.text.trim() != _ilkEmail.trim() ||
        _telefon.text.trim() != _ilkTelefon.trim();
  }

  Future<bool> _cikisaIzinVer() async {
    if (!_degisiklikVar || _kaydediliyor) {
      return true;
    }

    final sonuc = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Değişiklikler kaydedilmedi',
          ),
          content: const Text(
            'Yaptığınız değişiklikleri kaydetmeden çıkmak istediğinize emin misiniz?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Düzenlemeye Devam Et',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
              ),
              child: const Text(
                'Kaydetmeden Çık',
              ),
            ),
          ],
        );
      },
    );

    return sonuc ?? false;
  }

  Future<void> _geriDon() async {
    final cikabilir = await _cikisaIzinVer();

    if (!mounted || !cikabilir) {
      return;
    }

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profil/bilgilerim');
    }
  }

  Future<void> _kaydet() async {
    FocusScope.of(context).unfocus();

    final gecerli =
        _formAnahtari.currentState?.validate() ??
            false;

    if (!gecerli || _kaydediliyor) {
      return;
    }

    if (!_degisiklikVar) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Kaydedilecek bir değişiklik bulunmuyor.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    setState(() {
      _kaydediliyor = true;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .profilBilgileriniGuncelle(
            ad: _ad.text,
            soyad: _soyad.text,
            telefon: _telefon.text,
          );

      _ilkAd = _ad.text.trim();
      _ilkSoyad = _soyad.text.trim();
      _ilkEmail = _email.text.trim();
      _ilkTelefon = _telefon.text.trim();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Profil bilgileriniz güncellendi.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF15803D),
          ),
        );

      context.pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Profil bilgileri güncellenemedi.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFFDC2626),
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

  String? _adDogrula(
    String? deger,
  ) {
    final metin = deger?.trim() ?? '';

    if (metin.isEmpty) {
      return 'Ad alanı boş bırakılamaz.';
    }

    if (metin.length < 2) {
      return 'Ad en az 2 karakter olmalıdır.';
    }

    if (metin.length > 50) {
      return 'Ad en fazla 50 karakter olabilir.';
    }

    return null;
  }

  String? _soyadDogrula(
    String? deger,
  ) {
    final metin = deger?.trim() ?? '';

    if (metin.isEmpty) {
      return 'Soyad alanı boş bırakılamaz.';
    }

    if (metin.length < 2) {
      return 'Soyad en az 2 karakter olmalıdır.';
    }

    if (metin.length > 50) {
      return 'Soyad en fazla 50 karakter olabilir.';
    }

    return null;
  }

  String? _emailDogrula(
    String? deger,
  ) {
    final email = deger?.trim() ?? '';

    if (email.isEmpty) {
      return 'E-posta alanı boş bırakılamaz.';
    }

    final emailDeseni = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailDeseni.hasMatch(email)) {
      return 'Geçerli bir e-posta adresi yazın.';
    }

    return null;
  }

  String? _telefonDogrula(
    String? deger,
  ) {
    final telefon = deger?.trim() ?? '';

    // Telefon zorunlu değildir.
    if (telefon.isEmpty) {
      return null;
    }

    final sadeceRakamlar = telefon.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (sadeceRakamlar.length < 10 ||
        sadeceRakamlar.length > 12) {
      return 'Geçerli bir telefon numarası yazın.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final kullanici =
        ref.watch(authProvider).kullanici;

    if (kullanici == null) {
      return Scaffold(
        backgroundColor:
            const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor:
              const Color(0xFFF7F8FC),
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Profili Düzenle',
          ),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              context.go('/giris');
            },
            child: const Text(
              'Giriş Yap',
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: !_degisiklikVar,
      onPopInvokedWithResult: (
        didPop,
        result,
      ) async {
        if (didPop) {
          return;
        }

        await _geriDon();
      },
      child: Scaffold(
        backgroundColor:
            const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor:
              const Color(0xFFF7F8FC),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed:
                _kaydediliyor ? null : _geriDon,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Renkler.lacivert,
            ),
            tooltip: 'Geri',
          ),
          title: const Text(
            'Profili Düzenle',
            style: TextStyle(
              color: Renkler.lacivert,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            32,
          ),
          child: Form(
            key: _formAnahtari,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kişisel Bilgiler',
                  style: TextStyle(
                    color: Renkler.lacivert,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Profilinizde yer alan bilgileri buradan düzenleyebilirsiniz.',
                  style: TextStyle(
                    color: Renkler.metinIkincil,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 22),

                _ProfilGirdiAlani(
                  denetleyici: _ad,
                  etiket: 'Ad',
                  ipucu: 'Adınızı yazın',
                  ikon:
                      Icons.person_outline_rounded,
                  metinIslemi:
                      TextInputAction.next,
                  dogrulayici: _adDogrula,
                  etkin: !_kaydediliyor,
                ),

                const SizedBox(height: 16),

                _ProfilGirdiAlani(
                  denetleyici: _soyad,
                  etiket: 'Soyad',
                  ipucu: 'Soyadınızı yazın',
                  ikon: Icons.badge_outlined,
                  metinIslemi:
                      TextInputAction.next,
                  dogrulayici: _soyadDogrula,
                  etkin: !_kaydediliyor,
                ),

                const SizedBox(height: 16),

                _ProfilGirdiAlani(
                  denetleyici: _email,
                  etiket: 'E-posta',
                  ipucu:
                      'E-posta adresinizi yazın',
                  ikon:
                      Icons.mail_outline_rounded,
                  klavyeTipi:
                      TextInputType.emailAddress,
                  metinIslemi:
                      TextInputAction.next,
                  dogrulayici: _emailDogrula,
                  etkin: !_kaydediliyor,
                  otomatikDoldurma: const [
                    AutofillHints.email,
                  ],
                ),

                const SizedBox(height: 16),

                _ProfilGirdiAlani(
                  denetleyici: _telefon,
                  etiket: 'Telefon',
                  ipucu: '05XX XXX XX XX',
                  ikon: Icons.phone_outlined,
                  klavyeTipi:
                      TextInputType.phone,
                  metinIslemi:
                      TextInputAction.done,
                  dogrulayici:
                      _telefonDogrula,
                  etkin: !_kaydediliyor,
                  otomatikDoldurma: const [
                    AutofillHints.telephoneNumber,
                  ],
                  gonder: (_) {
                    _kaydet();
                  },
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _kaydediliyor ||
                                !_degisiklikVar
                            ? null
                            : _kaydet,
                    icon: _kaydediliyor
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons
                                .check_circle_outline_rounded,
                          ),
                    label: Text(
                      _kaydediliyor
                          ? 'Kaydediliyor...'
                          : 'Değişiklikleri Kaydet',
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Renkler.lacivert,
                      foregroundColor:
                          Colors.white,
                      disabledBackgroundColor:
                          const Color(
                        0xFFADB5BD,
                      ),
                      disabledForegroundColor:
                          Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                      textStyle:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFFEEF5FC,
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 19,
                        color: Renkler.lacivert,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Bu bilgiler şimdilik cihazda saklanır. Backend profil güncelleme özelliği eklendiğinde veritabanına da kaydedilecektir.',
                          style: TextStyle(
                            color: Renkler
                                .metinIkincil,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
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

class _ProfilGirdiAlani
    extends StatelessWidget {
  const _ProfilGirdiAlani({
    required this.denetleyici,
    required this.etiket,
    required this.ipucu,
    required this.ikon,
    required this.metinIslemi,
    required this.dogrulayici,
    required this.etkin,
    this.klavyeTipi,
    this.gonder,
    this.otomatikDoldurma,
  });

  final TextEditingController denetleyici;
  final String etiket;
  final String ipucu;
  final IconData ikon;
  final TextInputType? klavyeTipi;
  final TextInputAction metinIslemi;
  final String? Function(String?) dogrulayici;
  final ValueChanged<String>? gonder;
  final Iterable<String>? otomatikDoldurma;
  final bool etkin;

  @override
  Widget build(BuildContext context) {
    final emailAlani =
        klavyeTipi == TextInputType.emailAddress;

    return TextFormField(
      controller: denetleyici,
      enabled: etkin,
      keyboardType: klavyeTipi,
      textInputAction: metinIslemi,
      validator: dogrulayici,
      onFieldSubmitted: gonder,
      autofillHints: otomatikDoldurma,
      autocorrect: !emailAlani,
      enableSuggestions: !emailAlani,
      textCapitalization: emailAlani
          ? TextCapitalization.none
          : TextCapitalization.words,
      decoration: InputDecoration(
        labelText: etiket,
        hintText: ipucu,
        prefixIcon: Icon(
          ikon,
          color: Renkler.lacivert,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Renkler.kenarlik,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Renkler.kenarlik,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Renkler.mavi,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
            width: 1.6,
          ),
        ),
      ),
    );
  }
}