import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/renkler.dart';

class AyarlarEkrani extends StatefulWidget {
  const AyarlarEkrani({
    super.key,
  });

  @override
  State<AyarlarEkrani> createState() {
    return _AyarlarEkraniDurumu();
  }
}

class _AyarlarEkraniDurumu extends State<AyarlarEkrani> {
  bool _bildirimlerAcik = true;

  void _bilgiMesaji(
    String mesaj,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mesaj),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _geriDon() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profil');
    }
  }

  Future<void> _dilSeciminiGoster() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            28,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
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
                    color: const Color(
                      0xFFD0D5DD,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Uygulama Dili',
                style: TextStyle(
                  color: Renkler.lacivert,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Şimdilik yalnızca Türkçe desteklenmektedir.',
                style: TextStyle(
                  color: Renkler.metinIkincil,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF5FC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: Renkler.lacivert,
                  ),
                ),
                title: const Text(
                  'Türkçe',
                  style: TextStyle(
                    color: Renkler.lacivert,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF15803D),
                ),
                onTap: () {
                  Navigator.of(
                    bottomSheetContext,
                  ).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uygulamaHakkindaGoster() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF5FC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business_center_outlined,
              color: Renkler.lacivert,
              size: 29,
            ),
          ),
          title: const Text(
            'ASB Platform',
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'Firmalar, duyurular, harita ve diğer kurumsal '
            'hizmetlere tek bir uygulama üzerinden erişmenizi sağlar.\n\n'
            'Sürüm: 1.0.0',
            textAlign: TextAlign.center,
          ),
          actionsAlignment:
              MainAxisAlignment.center,
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor:
                    Renkler.lacivert,
              ),
              child: const Text(
                'Tamam',
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF7F8FC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _geriDon,
          tooltip: 'Geri',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Renkler.lacivert,
          ),
        ),
        title: const Text(
          'Ayarlar',
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
          8,
          16,
          32,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const _BilgiKarti(),

            const SizedBox(height: 26),

            const _BolumBasligi(
              baslik: 'Tercihler',
            ),

            const SizedBox(height: 10),

            _AyarlarKarti(
              children: [
                _AnahtarliAyarSatiri(
                  ikon: Icons
                      .notifications_none_rounded,
                  baslik: 'Bildirimler',
                  aciklama:
                      'Uygulama bildirimlerini yönetin',
                  deger: _bildirimlerAcik,
                  onChanged: (deger) {
                    setState(() {
                      _bildirimlerAcik = deger;
                    });

                    _bilgiMesaji(
                      deger
                          ? 'Bildirimler açıldı.'
                          : 'Bildirimler kapatıldı.',
                    );
                  },
                ),

                const _AyarAyirici(),

                _OkAyarSatiri(
                  ikon: Icons.language_rounded,
                  baslik: 'Dil',
                  aciklama:
                      'Uygulama dilini görüntüleyin',
                  sagMetin: 'Türkçe',
                  onTap: _dilSeciminiGoster,
                ),
              ],
            ),

            const SizedBox(height: 26),

            const _BolumBasligi(
              baslik: 'Gizlilik ve Güvenlik',
            ),

            const SizedBox(height: 10),

            _AyarlarKarti(
              children: [
                _OkAyarSatiri(
                  ikon:
                      Icons.privacy_tip_outlined,
                  baslik:
                      'Gizlilik Politikası',
                  aciklama:
                      'Verilerinizin nasıl kullanıldığını inceleyin',
                  onTap: () {
                    _bilgiMesaji(
                      'Gizlilik politikası sayfası daha sonra eklenecek.',
                    );
                  },
                ),

                const _AyarAyirici(),

                _OkAyarSatiri(
                  ikon: Icons.shield_outlined,
                  baslik:
                      'KVKK Aydınlatma Metni',
                  aciklama:
                      'Kişisel veriler hakkındaki metni inceleyin',
                  onTap: () {
                    _bilgiMesaji(
                      'KVKK aydınlatma metni daha sonra eklenecek.',
                    );
                  },
                ),

                const _AyarAyirici(),

                _OkAyarSatiri(
                  ikon:
                      Icons.description_outlined,
                  baslik:
                      'Kullanım Koşulları',
                  aciklama:
                      'Uygulama kullanım şartlarını inceleyin',
                  onTap: () {
                    _bilgiMesaji(
                      'Kullanım koşulları sayfası daha sonra eklenecek.',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 26),

            const _BolumBasligi(
              baslik: 'Uygulama',
            ),

            const SizedBox(height: 10),

            _AyarlarKarti(
              children: [
                _OkAyarSatiri(
                  ikon:
                      Icons.info_outline_rounded,
                  baslik:
                      'Uygulama Hakkında',
                  aciklama:
                      'Uygulama ve geliştirici bilgileri',
                  onTap:
                      _uygulamaHakkindaGoster,
                ),

                const _AyarAyirici(),

                const _BilgiAyarSatiri(
                  ikon: Icons
                      .system_update_alt_rounded,
                  baslik: 'Sürüm',
                  aciklama:
                      'Yüklü uygulama sürümü',
                  deger: '1.0.0',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BilgiKarti extends StatelessWidget {
  const _BilgiKarti();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF082F61),
            Color(0xFF0F5AA6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26082F61),
            blurRadius: 18,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tune_rounded,
            color: Colors.white,
            size: 32,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Uygulama tercihlerinizi yönetin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Bildirim, dil, gizlilik ve uygulama bilgilerine buradan ulaşabilirsiniz.',
                  style: TextStyle(
                    color: Color(0xFFDCEBFA),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BolumBasligi extends StatelessWidget {
  const _BolumBasligi({
    required this.baslik,
  });

  final String baslik;

  @override
  Widget build(BuildContext context) {
    return Text(
      baslik,
      style: const TextStyle(
        color: Renkler.lacivert,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AyarlarKarti extends StatelessWidget {
  const _AyarlarKarti({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Renkler.kenarlik,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _AnahtarliAyarSatiri
    extends StatelessWidget {
  const _AnahtarliAyarSatiri({
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    required this.deger,
    required this.onChanged,
  });

  final IconData ikon;
  final String baslik;
  final String aciklama;
  final bool deger;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _AyarSatiriGovdesi(
      ikon: ikon,
      baslik: baslik,
      aciklama: aciklama,
      sagBolum: Switch.adaptive(
        value: deger,
        activeThumbColor: Renkler.lacivert,
        onChanged: onChanged,
      ),
      onTap: () {
        onChanged(!deger);
      },
    );
  }
}

class _OkAyarSatiri extends StatelessWidget {
  const _OkAyarSatiri({
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    required this.onTap,
    this.sagMetin,
  });

  final IconData ikon;
  final String baslik;
  final String aciklama;
  final VoidCallback? onTap;
  final String? sagMetin;

  @override
  Widget build(BuildContext context) {
    return _AyarSatiriGovdesi(
      ikon: ikon,
      baslik: baslik,
      aciklama: aciklama,
      onTap: onTap,
      sagBolum: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (sagMetin != null) ...[
            Text(
              sagMetin!,
              style: const TextStyle(
                color:
                    Renkler.metinIkincil,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 7),
          ],
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF667085),
          ),
        ],
      ),
    );
  }
}

class _BilgiAyarSatiri
    extends StatelessWidget {
  const _BilgiAyarSatiri({
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    required this.deger,
  });

  final IconData ikon;
  final String baslik;
  final String aciklama;
  final String deger;

  @override
  Widget build(BuildContext context) {
    return _AyarSatiriGovdesi(
      ikon: ikon,
      baslik: baslik,
      aciklama: aciklama,
      sagBolum: Text(
        deger,
        style: const TextStyle(
          color: Renkler.metinIkincil,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AyarSatiriGovdesi
    extends StatelessWidget {
  const _AyarSatiriGovdesi({
    required this.ikon,
    required this.baslik,
    required this.aciklama,
    required this.sagBolum,
    this.onTap,
  });

  final IconData ikon;
  final String baslik;
  final String aciklama;
  final Widget sagBolum;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration:
                    const BoxDecoration(
                  color: Color(0xFFEEF5FC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ikon,
                  color: Renkler.lacivert,
                  size: 22,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      baslik,
                      style: const TextStyle(
                        color: Renkler.lacivert,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      aciklama,
                      style: const TextStyle(
                        color:
                            Renkler.metinIkincil,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              sagBolum,
            ],
          ),
        ),
      ),
    );
  }
}

class _AyarAyirici extends StatelessWidget {
  const _AyarAyirici();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 73,
      endIndent: 16,
      color: Renkler.kenarlik,
    );
  }
}