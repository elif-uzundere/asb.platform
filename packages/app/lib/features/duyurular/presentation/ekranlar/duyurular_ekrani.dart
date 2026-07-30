import 'package:flutter/material.dart';

import 'duyuru_detay_ekrani.dart';

class DuyurularEkrani extends StatelessWidget {
  const DuyurularEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Duyurular'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DuyuruKarti(
            baslik: 'Sistem Bakım Duyurusu',
            kategori: 'Genel',
            tarih: '29 Temmuz 2026',
            kisaIcerik: 'Sistem pazar günü kısa süreli bakımda olacaktır...',
            tamIcerik:
                'Sistem pazar günü saat 10.00 ile 12.00 arasında bakım çalışması nedeniyle kısa süreli olarak kullanıma kapalı olacaktır.',
          ),
          const SizedBox(height: 12),
          _DuyuruKarti(
            baslik: 'Yeni Hizmet Duyurusu',
            kategori: 'Hizmet',
            tarih: '28 Temmuz 2026',
            kisaIcerik: 'Yeni hizmetimiz kullanıcıların erişimine açıldı...',
            tamIcerik:
                'Yeni hizmetimiz kullanıcıların erişimine açılmıştır. Ayrıntılı bilgi için ilgili hizmet sayfasını ziyaret edebilirsiniz.',
          ),
        ],
      ),
    );
  }
}

class _DuyuruKarti extends StatelessWidget {
  const _DuyuruKarti({
    required this.baslik,
    required this.kategori,
    required this.tarih,
    required this.kisaIcerik,
    required this.tamIcerik,
  });

  final String baslik;
  final String kategori;
  final String tarih;
  final String kisaIcerik;
  final String tamIcerik;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.campaign_outlined),
        title: Text(baslik),
        subtitle: Text('$kategori • $tarih\n$kisaIcerik'),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DuyuruDetayEkrani(
                baslik: baslik,
                icerik: tamIcerik,
                kategori: kategori,
                tarih: tarih,
              ),
            ),
          );
        },
      ),
    );
  }
}