import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';

class SifreDegistirEkrani extends StatefulWidget {
  const SifreDegistirEkrani({
    super.key,
  });

  @override
  State<SifreDegistirEkrani> createState() {
    return _SifreDegistirEkraniDurumu();
  }
}

class _SifreDegistirEkraniDurumu
    extends State<SifreDegistirEkrani> {
  final _formAnahtari = GlobalKey<FormState>();

  final _mevcutSifre = TextEditingController();
  final _yeniSifre = TextEditingController();
  final _yeniSifreTekrar = TextEditingController();

  bool _mevcutSifreGorunur = false;
  bool _yeniSifreGorunur = false;
  bool _tekrarSifreGorunur = false;

  @override
  void dispose() {
    _mevcutSifre.dispose();
    _yeniSifre.dispose();
    _yeniSifreTekrar.dispose();
    super.dispose();
  }

  String? _mevcutSifreDogrula(
    String? deger,
  ) {
    final sifre = deger ?? '';

    if (sifre.isEmpty) {
      return 'Mevcut şifrenizi yazın.';
    }

    return null;
  }

  String? _yeniSifreDogrula(
    String? deger,
  ) {
    final sifre = deger ?? '';

    if (sifre.isEmpty) {
      return 'Yeni şifrenizi yazın.';
    }

    if (sifre.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır.';
    }

    if (!RegExp(r'[0-9]').hasMatch(sifre)) {
      return 'Şifre en az bir rakam içermelidir.';
    }

    if (sifre == _mevcutSifre.text) {
      return 'Yeni şifre mevcut şifreyle aynı olamaz.';
    }

    return null;
  }

  String? _tekrarSifreDogrula(
    String? deger,
  ) {
    final sifre = deger ?? '';

    if (sifre.isEmpty) {
      return 'Yeni şifrenizi tekrar yazın.';
    }

    if (sifre != _yeniSifre.text) {
      return 'Yeni şifreler birbiriyle eşleşmiyor.';
    }

    return null;
  }

  void _kaydet() {
    FocusScope.of(context).unfocus();

    final formGecerli =
        _formAnahtari.currentState?.validate() ?? false;

    if (!formGecerli) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Şifre değiştirme servisi henüz backend tarafına bağlanmadı.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profil');
            }
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Renkler.lacivert,
          ),
          tooltip: 'Geri',
        ),
        title: const Text(
          'Şifre Değiştir',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF5FC),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_reset_rounded,
                      color: Renkler.lacivert,
                      size: 30,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hesap Güvenliği',
                            style: TextStyle(
                              color: Renkler.lacivert,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Güvenliğiniz için güçlü ve daha önce kullanmadığınız bir şifre belirleyin.',
                            style: TextStyle(
                              color: Renkler.metinIkincil,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Şifre Bilgileri',
                style: TextStyle(
                  color: Renkler.lacivert,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              _SifreAlani(
                denetleyici: _mevcutSifre,
                etiket: 'Mevcut Şifre',
                ipucu: 'Mevcut şifrenizi yazın',
                gizli: !_mevcutSifreGorunur,
                dogrulayici: _mevcutSifreDogrula,
                metinIslemi: TextInputAction.next,
                gozBasildi: () {
                  setState(() {
                    _mevcutSifreGorunur =
                        !_mevcutSifreGorunur;
                  });
                },
              ),

              const SizedBox(height: 16),

              _SifreAlani(
                denetleyici: _yeniSifre,
                etiket: 'Yeni Şifre',
                ipucu: 'Yeni şifrenizi yazın',
                gizli: !_yeniSifreGorunur,
                dogrulayici: _yeniSifreDogrula,
                metinIslemi: TextInputAction.next,
                gozBasildi: () {
                  setState(() {
                    _yeniSifreGorunur =
                        !_yeniSifreGorunur;
                  });
                },
              ),

              const SizedBox(height: 16),

              _SifreAlani(
                denetleyici: _yeniSifreTekrar,
                etiket: 'Yeni Şifre Tekrar',
                ipucu: 'Yeni şifrenizi tekrar yazın',
                gizli: !_tekrarSifreGorunur,
                dogrulayici: _tekrarSifreDogrula,
                metinIslemi: TextInputAction.done,
                gozBasildi: () {
                  setState(() {
                    _tekrarSifreGorunur =
                        !_tekrarSifreGorunur;
                  });
                },
                gonder: (_) {
                  _kaydet();
                },
              ),

              const SizedBox(height: 14),

              const Text(
                'Şifreniz en az 8 karakter ve en az bir rakam içermelidir.',
                style: TextStyle(
                  color: Renkler.metinIkincil,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _kaydet,
                  icon: const Icon(
                    Icons.lock_reset_rounded,
                  ),
                  label: const Text(
                    'Şifreyi Değiştir',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Renkler.lacivert,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SifreAlani extends StatelessWidget {
  const _SifreAlani({
    required this.denetleyici,
    required this.etiket,
    required this.ipucu,
    required this.gizli,
    required this.dogrulayici,
    required this.metinIslemi,
    required this.gozBasildi,
    this.gonder,
  });

  final TextEditingController denetleyici;
  final String etiket;
  final String ipucu;
  final bool gizli;
  final String? Function(String?) dogrulayici;
  final TextInputAction metinIslemi;
  final VoidCallback gozBasildi;
  final ValueChanged<String>? gonder;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: denetleyici,
      obscureText: gizli,
      validator: dogrulayici,
      textInputAction: metinIslemi,
      onFieldSubmitted: gonder,
      autofillHints: const [
        AutofillHints.password,
      ],
      decoration: InputDecoration(
        labelText: etiket,
        hintText: ipucu,
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: Renkler.lacivert,
        ),
        suffixIcon: IconButton(
          onPressed: gozBasildi,
          icon: Icon(
            gizli
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Renkler.metinIkincil,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Renkler.kenarlik,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Renkler.kenarlik,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Renkler.mavi,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
            width: 1.6,
          ),
        ),
      ),
    );
  }
}