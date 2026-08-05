import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';

class EpostaDegistirEkrani extends StatefulWidget {
  const EpostaDegistirEkrani({
    super.key,
  });

  @override
  State<EpostaDegistirEkrani> createState() {
    return _EpostaDegistirEkraniDurumu();
  }
}

class _EpostaDegistirEkraniDurumu
    extends State<EpostaDegistirEkrani> {
  final _formAnahtari = GlobalKey<FormState>();

  final _yeniEposta = TextEditingController();
  final _mevcutSifre = TextEditingController();
  final _dogrulamaKodu = TextEditingController();

  bool _sifreGorunur = false;
  bool _kodGonderildi = false;
  bool _islemYapiliyor = false;

  @override
  void dispose() {
    _yeniEposta.dispose();
    _mevcutSifre.dispose();
    _dogrulamaKodu.dispose();
    super.dispose();
  }

  String? _epostaDogrula(
    String? deger,
  ) {
    final eposta = deger?.trim() ?? '';

    if (eposta.isEmpty) {
      return 'Yeni e-posta adresinizi yazın.';
    }

    final epostaDeseni = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!epostaDeseni.hasMatch(eposta)) {
      return 'Geçerli bir e-posta adresi yazın.';
    }

    return null;
  }

  String? _sifreDogrula(
    String? deger,
  ) {
    final sifre = deger ?? '';

    if (sifre.isEmpty) {
      return 'Mevcut şifrenizi yazın.';
    }

    return null;
  }

  String? _kodDogrula(
    String? deger,
  ) {
    if (!_kodGonderildi) {
      return null;
    }

    final kod = deger?.trim() ?? '';

    if (kod.isEmpty) {
      return 'Doğrulama kodunu yazın.';
    }

    if (kod.length != 6) {
      return 'Kod 6 haneli olmalıdır.';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(kod)) {
      return 'Kod yalnızca rakamlardan oluşmalıdır.';
    }

    return null;
  }

  Future<void> _kodGonder() async {
    FocusScope.of(context).unfocus();

    final epostaHatasi = _epostaDogrula(
      _yeniEposta.text,
    );

    final sifreHatasi = _sifreDogrula(
      _mevcutSifre.text,
    );

    if (epostaHatasi != null ||
        sifreHatasi != null) {
      _formAnahtari.currentState?.validate();
      return;
    }

    if (_islemYapiliyor) {
      return;
    }

    setState(() {
      _islemYapiliyor = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _islemYapiliyor = false;
      _kodGonderildi = true;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Doğrulama kodu ${_yeniEposta.text.trim()} adresine gönderilecek.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _epostayiDegistir() async {
    FocusScope.of(context).unfocus();

    final formGecerli =
        _formAnahtari.currentState?.validate() ??
            false;

    if (!formGecerli || !_kodGonderildi) {
      if (!_kodGonderildi) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Önce doğrulama kodu gönderin.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }

      return;
    }

    if (_islemYapiliyor) {
      return;
    }

    setState(() {
      _islemYapiliyor = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _islemYapiliyor = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'E-posta değiştirme servisi henüz backend tarafına bağlanmadı.',
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
          onPressed: _islemYapiliyor
              ? null
              : () {
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
          'E-posta Değiştir',
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
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
                            'E-posta Güvenliği',
                            style: TextStyle(
                              color: Renkler.lacivert,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Yeni e-posta adresinizi doğruladıktan sonra hesabınıza tanımlayabilirsiniz.',
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
                'E-posta Bilgileri',
                style: TextStyle(
                  color: Renkler.lacivert,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 14),

              _FormAlani(
                denetleyici: _yeniEposta,
                etiket: 'Yeni E-posta',
                ipucu: 'Yeni e-posta adresinizi yazın',
                ikon: Icons.mail_outline_rounded,
                klavyeTipi: TextInputType.emailAddress,
                metinIslemi: TextInputAction.next,
                dogrulayici: _epostaDogrula,
                etkin: !_kodGonderildi &&
                    !_islemYapiliyor,
              ),

              const SizedBox(height: 16),

              _FormAlani(
                denetleyici: _mevcutSifre,
                etiket: 'Mevcut Şifre',
                ipucu: 'Mevcut şifrenizi yazın',
                ikon: Icons.lock_outline_rounded,
                metinIslemi: TextInputAction.done,
                dogrulayici: _sifreDogrula,
                gizli: !_sifreGorunur,
                etkin: !_kodGonderildi &&
                    !_islemYapiliyor,
                sonEk: IconButton(
                  onPressed: () {
                    setState(() {
                      _sifreGorunur =
                          !_sifreGorunur;
                    });
                  },
                  icon: Icon(
                    _sifreGorunur
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Renkler.metinIkincil,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                      _islemYapiliyor || _kodGonderildi
                          ? null
                          : _kodGonder,
                  icon: _islemYapiliyor &&
                          !_kodGonderildi
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send_outlined,
                        ),
                  label: Text(
                    _kodGonderildi
                        ? 'Kod Gönderildi'
                        : 'Doğrulama Kodu Gönder',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Renkler.lacivert,
                    side: const BorderSide(
                      color: Renkler.lacivert,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              if (_kodGonderildi) ...[
                const SizedBox(height: 24),

                const Text(
                  'Doğrulama',
                  style: TextStyle(
                    color: Renkler.lacivert,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  '${_yeniEposta.text.trim()} adresine gönderilen 6 haneli kodu yazın.',
                  style: const TextStyle(
                    color: Renkler.metinIkincil,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 14),

                _FormAlani(
                  denetleyici: _dogrulamaKodu,
                  etiket: 'Doğrulama Kodu',
                  ipucu: '6 haneli kod',
                  ikon:
                      Icons.verified_user_outlined,
                  klavyeTipi: TextInputType.number,
                  metinIslemi:
                      TextInputAction.done,
                  dogrulayici: _kodDogrula,
                  etkin: !_islemYapiliyor,
                  gonder: (_) {
                    _epostayiDegistir();
                  },
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _islemYapiliyor
                        ? null
                        : () {
                            setState(() {
                              _kodGonderildi = false;
                              _dogrulamaKodu.clear();
                            });
                          },
                    child: const Text(
                      'E-postayı Değiştir',
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _islemYapiliyor
                        ? null
                        : _epostayiDegistir,
                    icon: _islemYapiliyor
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
                      _islemYapiliyor
                          ? 'Kontrol ediliyor...'
                          : 'E-postayı Değiştir',
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Renkler.lacivert,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FormAlani extends StatelessWidget {
  const _FormAlani({
    required this.denetleyici,
    required this.etiket,
    required this.ipucu,
    required this.ikon,
    required this.metinIslemi,
    required this.dogrulayici,
    required this.etkin,
    this.klavyeTipi,
    this.gizli = false,
    this.sonEk,
    this.gonder,
  });

  final TextEditingController denetleyici;
  final String etiket;
  final String ipucu;
  final IconData ikon;
  final TextInputType? klavyeTipi;
  final TextInputAction metinIslemi;
  final String? Function(String?) dogrulayici;
  final bool etkin;
  final bool gizli;
  final Widget? sonEk;
  final ValueChanged<String>? gonder;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: denetleyici,
      enabled: etkin,
      obscureText: gizli,
      keyboardType: klavyeTipi,
      textInputAction: metinIslemi,
      validator: dogrulayici,
      onFieldSubmitted: gonder,
      autocorrect:
          klavyeTipi != TextInputType.emailAddress,
      enableSuggestions:
          klavyeTipi != TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: etiket,
        hintText: ipucu,
        prefixIcon: Icon(
          ikon,
          color: Renkler.lacivert,
        ),
        suffixIcon: sonEk,
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