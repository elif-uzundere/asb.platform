// İş ilanı domain kuralları — başvuru/oluşturma/sahiplik görünürlük kararları.

import 'package:asb_app/core/models/auth_modelleri.dart';
import 'package:asb_app/core/models/is_ilani_modelleri.dart';
import 'package:asb_app/features/is_ilanlari/domain/is_ilani_kurallari.dart';
import 'package:flutter_test/flutter_test.dart';

IsIlaniResponse _ilan({IsIlaniDurumu durum = IsIlaniDurumu.aktif, String firmaId = 'f1'}) => IsIlaniResponse(
      id: 'i1',
      firmaId: firmaId,
      firmaAdi: 'Test A.Ş.',
      baslik: 'Depo Sorumlusu',
      aciklama: 'Açıklama',
      konum: null,
      yayinTarihi: DateTime(2026, 1, 1),
      durum: durum,
    );

KullaniciOzet _kullanici({
  KullaniciRolu rol = KullaniciRolu.ziyaretci,
  String? firmaId,
  List<String> yetkiler = const [],
}) =>
    KullaniciOzet(
      id: 'k1',
      ad: 'Ad',
      soyad: 'Soyad',
      email: 'test@example.com',
      telefon: null,
      rol: rol,
      firmaId: firmaId,
      cookzoneIsletmeId: null,
      epostaDogrulandi: true,
      yetkiler: yetkiler,
    );

void main() {
  group('basvuruYapilabilirMi', () {
    test('giris yapilmamissa basvurulamaz', () {
      expect(basvuruYapilabilirMi(_ilan(), null), isFalse);
    });

    test('ilan kapaliysa basvurulamaz', () {
      final kullanici = _kullanici();
      expect(basvuruYapilabilirMi(_ilan(durum: IsIlaniDurumu.kapali), kullanici), isFalse);
    });

    test('kendi firmasinin ilanina basvuramaz', () {
      final kullanici = _kullanici(rol: KullaniciRolu.firmaYetkilisi, firmaId: 'f1');
      expect(basvuruYapilabilirMi(_ilan(firmaId: 'f1'), kullanici), isFalse);
    });

    test('aktif ilana, baska firmadan/ziyaretciden basvurulabilir', () {
      final kullanici = _kullanici();
      expect(basvuruYapilabilirMi(_ilan(), kullanici), isTrue);
    });
  });

  group('ilanOlusturulabilirMi', () {
    test('is_ilani_yonet yetkisi olmayan kimse ilan olusturamaz', () {
      expect(ilanOlusturulabilirMi(null), isFalse);
      expect(ilanOlusturulabilirMi(_kullanici(rol: KullaniciRolu.ziyaretci)), isFalse);
      expect(ilanOlusturulabilirMi(_kullanici(rol: KullaniciRolu.admin)), isFalse);
      // Rolü firma_yetkilisi olsa bile yetki admin panelinden verilmemişse olmaz —
      // sabit rol kontrolü DEĞİL, RolYetki'ye bakılıyor (18.08.2026).
      expect(ilanOlusturulabilirMi(_kullanici(rol: KullaniciRolu.firmaYetkilisi)), isFalse);
    });

    test('is_ilani_yonet yetkisi olan (rolü ne olursa olsun) ilan olusturabilir', () {
      expect(
        ilanOlusturulabilirMi(_kullanici(rol: KullaniciRolu.firmaYetkilisi, yetkiler: ['is_ilani_yonet'])),
        isTrue,
      );
      expect(
        ilanOlusturulabilirMi(_kullanici(rol: KullaniciRolu.admin, yetkiler: ['is_ilani_yonet'])),
        isTrue,
      );
    });
  });

  group('ilanSahibiMi', () {
    test('farkli firmanin yetkilisi sahip degildir', () {
      final kullanici = _kullanici(rol: KullaniciRolu.firmaYetkilisi, firmaId: 'f2', yetkiler: ['is_ilani_yonet']);
      expect(ilanSahibiMi(_ilan(firmaId: 'f1'), kullanici), isFalse);
    });

    test('ayni firmanin yetkili kullanicisi sahiptir', () {
      final kullanici = _kullanici(rol: KullaniciRolu.firmaYetkilisi, firmaId: 'f1', yetkiler: ['is_ilani_yonet']);
      expect(ilanSahibiMi(_ilan(firmaId: 'f1'), kullanici), isTrue);
    });

    test('ayni firmada olsa bile is_ilani_yonet yetkisi yoksa sahip degildir', () {
      final kullanici = _kullanici(rol: KullaniciRolu.firmaCalisani, firmaId: 'f1');
      expect(ilanSahibiMi(_ilan(firmaId: 'f1'), kullanici), isFalse);
    });

    test('ziyaretci hicbir zaman sahip degildir', () {
      final kullanici = _kullanici(rol: KullaniciRolu.ziyaretci, firmaId: 'f1');
      expect(ilanSahibiMi(_ilan(firmaId: 'f1'), kullanici), isFalse);
    });
  });

  group('durumEtiketi', () {
    test('aktif/kapali dogru etikete cevrilir', () {
      expect(durumEtiketi(IsIlaniDurumu.aktif), 'Aktif');
      expect(durumEtiketi(IsIlaniDurumu.kapali), 'Kapalı');
    });
  });

  group('basvuruIcinUygunKararlar', () {
    test('mevcut durum listede yok, digerleri var', () {
      final kararlar = basvuruIcinUygunKararlar(IsBasvurusuDurumu.beklemede);
      expect(kararlar, containsAll([IsBasvurusuKarari.incelendi, IsBasvurusuKarari.reddedildi, IsBasvurusuKarari.kabul]));
    });

    test('kabul edilmis basvuru icin kabul secenegi tekrar gosterilmez', () {
      final kararlar = basvuruIcinUygunKararlar(IsBasvurusuDurumu.kabul);
      expect(kararlar, isNot(contains(IsBasvurusuKarari.kabul)));
      expect(kararlar, containsAll([IsBasvurusuKarari.incelendi, IsBasvurusuKarari.reddedildi]));
    });

    test('beklemedeye geri donus secenegi hic yok', () {
      for (final durum in IsBasvurusuDurumu.values) {
        final kararlar = basvuruIcinUygunKararlar(durum);
        expect(kararlar.map((k) => k.deger), isNot(contains('beklemede')));
      }
    });
  });
}
