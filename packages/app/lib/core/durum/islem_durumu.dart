// Form gönderimi gibi TEK SEFERLİK işlemlerin ortak durumu.
//
// Amaç: ekranların `bool _yukleniyor` + `try/catch` + `setState` üçlüsünü
// kendi içlerinde tekrar etmesini engellemek. Ekran sadece durumu dinler,
// kararı notifier verir (bkz. docs/CLAUDE.md mimari kuralları — iş mantığı
// görünüm katmanında durmaz).

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_hata.dart';

@immutable
sealed class IslemDurumu {
  const IslemDurumu();
}

class IslemBosta extends IslemDurumu {
  const IslemBosta();
}

class IslemSuruyor extends IslemDurumu {
  const IslemSuruyor();
}

class IslemBasarili extends IslemDurumu {
  const IslemBasarili();
}

class IslemHatali extends IslemDurumu {
  const IslemHatali(this.mesaj);

  /// Backend'in Türkçe `error.message`'ı — ekran bunu olduğu gibi gösterir,
  /// kod→metin eşlemesi yapmaz.
  final String mesaj;
}

/// Form gönderen notifier'lar için taban sınıf.
abstract class FormNotifier extends StateNotifier<IslemDurumu> {
  FormNotifier() : super(const IslemBosta());

  /// İşlemi çalıştırıp durumu yönetir. Çift gönderimi (kullanıcının butona
  /// iki kez basması) burada engelleniyor — her ekranın ayrı ayrı düşünmesi
  /// gereken bir kural olmaktan çıktı.
  @protected
  Future<void> calistir(Future<void> Function() islem) async {
    if (state is IslemSuruyor) return;
    state = const IslemSuruyor();
    try {
      await islem();
      if (mounted) state = const IslemBasarili();
    } on ApiHata catch (hata) {
      if (mounted) state = IslemHatali(hata.mesaj);
    }
  }

  /// Hata/başarı ekranda gösterildikten sonra çağrılır.
  void sifirla() {
    if (mounted) state = const IslemBosta();
  }
}
