// Kullanıcının bir acil durumu bildirmesi (BR-5: konum toplanmıyor — harita
// modülü kapsam dışı — bu yüzden açıklama zorunlu). Bildirimler AdminJS
// panelinden (admin) incelenip kapatılıyor, ayrı bir "yetkili" rolü/ekranı
// YOK (13.08.2026, Berzan'ın kararı — izlencede böyle bir rol planlanmamıştı).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/durum/islem_durumu.dart';
import '../../../../core/theme/renkler.dart';
import '../../../../core/widgets/form_ogeleri.dart';
import '../../../../core/widgets/islem_geri_bildirimi.dart';
import '../../domain/acil_durum_bildirimi.dart';
import '../durum/acil_durum_bildirimi_durumu.dart';

class AcilDurumBildirEkrani extends ConsumerStatefulWidget {
  const AcilDurumBildirEkrani({super.key});

  @override
  ConsumerState<AcilDurumBildirEkrani> createState() => _AcilDurumBildirEkraniDurumu();
}

class _AcilDurumBildirEkraniDurumu extends ConsumerState<AcilDurumBildirEkrani> {
  final _aciklama = TextEditingController();
  AcilDurumTuru _seciliTur = AcilDurumTuru.yangin;

  @override
  void dispose() {
    _aciklama.dispose();
    super.dispose();
  }

  void _gonder() {
    ref.read(acilDurumBildirimiNotifierProvider.notifier).gonder(_seciliTur, _aciklama.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<IslemDurumu>(acilDurumBildirimiNotifierProvider, (_, sonraki) {
      islemGeriBildirimi(
        context,
        sonraki,
        hataBasligi: 'Bildirim gönderilemedi',
        basariBasligi: 'Bildiriminiz alındı',
        basariMesaji: 'İlgili birim en kısa sürede bildiriminizi inceleyecek.',
        basariSonrasi: () => Navigator.of(context).pop(),
        sifirla: ref.read(acilDurumBildirimiNotifierProvider.notifier).sifirla,
      );
    });

    final yukleniyor = ref.watch(acilDurumBildirimiNotifierProvider) is IslemSuruyor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF102F68),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/acil-durum');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text(
          'Acil Durum Bildir',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
        children: [
          const Text(
            'Tür',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AcilDurumTuru.values.map((tur) {
              final seciliMi = tur == _seciliTur;
              return ChoiceChip(
                label: Text(tur.etiket),
                selected: seciliMi,
                onSelected: yukleniyor ? null : (_) => setState(() => _seciliTur = tur),
                selectedColor: Renkler.lacivert,
                labelStyle: TextStyle(
                  color: seciliMi ? Colors.white : const Color(0xFF111827),
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE7E9EE)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Açıklama',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 10),
          GirdiKutusu(
            denetleyici: _aciklama,
            ipucu: 'Ne oldu, nerede? Kısaca açıklayın',
            ikon: Icons.notes_rounded,
          ),
          const SizedBox(height: 24),
          BirincilButon(
            yazi: yukleniyor ? 'Gönderiliyor...' : 'Bildirimi Gönder',
            yukleniyor: yukleniyor,
            basildi: _gonder,
          ),
        ],
      ),
    );
  }
}
