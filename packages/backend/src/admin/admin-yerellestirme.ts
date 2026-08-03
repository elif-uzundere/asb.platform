import type { Locale } from 'adminjs';

/**
 * AdminJS varsayılan olarak İngilizce gelir. Panel bu projenin tek admin
 * arayüzü olacağı için (bkz. docs/CLAUDE.md AdminJS kararı) Türkçeleştirildi.
 *
 * ÖNEMLİ — neden `language: 'en'` (ayrı bir 'tr' dili DEĞİL): İlk denemede
 * `language: 'tr', availableLanguages: ['tr']` kullanılmıştı. Bu, i18next'in
 * AdminJS'in kendi paketiyle gelen İngilizce varsayılan çevirilerine (login
 * sayfası, ana ekran "onboarding" kartları gibi henüz Türkçeleştirilmemiş
 * anahtarlar için) düşmesini KIRDI — ekranda çeviri yerine ham anahtar adları
 * ("welcomeOnBoard_title" gibi) görünüyordu (elle doğrulandı, ekran
 * görüntüsüyle bildirildi). Çözüm: yeni bir dil icat etmek yerine 'en'
 * dilinin KENDİ metinlerinin üzerine Türkçe yazmak — böylece çevirmediğim
 * (ya da unuttuğum) her anahtar otomatik olarak İngilizce varsayılana değil,
 * zaten üzerine yazdığım aynı dilin içine düşüyor, kırık/ham anahtar riski
 * kalmıyor.
 */
export const adminYerellestirme: Locale = {
  language: 'en',
  availableLanguages: ['en'],
  translations: {
    en: {
      actions: {
        new: 'Yeni Ekle',
        edit: 'Düzenle',
        show: 'Görüntüle',
        delete: 'Sil',
        bulkDelete: 'Seçilenleri Sil',
        list: 'Liste',
        search: 'Ara',
      },
      buttons: {
        save: 'Kaydet',
        addNewItem: 'Yeni Ekle',
        filter: 'Filtrele',
        filterActive: 'Filtrele ({{count}})',
        applyChanges: 'Uygula',
        resetFilter: 'Filtreyi Temizle',
        confirmRemovalMany: '{{count}} kaydı sil',
        confirmRemovalMany_plural: '{{count}} kaydı sil',
        logout: 'Çıkış Yap',
        login: 'Giriş Yap',
        createFirstRecord: 'İlk kaydı oluştur',
        cancel: 'Vazgeç',
        confirm: 'Onayla',
        contactUs: 'Bize Ulaşın',
        edit: 'Düzenle',
        show: 'Görüntüle',
        hide: 'Gizle',
        seeItems: 'Öğeleri gör',
        goBack: 'Geri dön',
      },
      components: {
        Login: {
          welcomeHeader: 'Hoş geldiniz',
          welcomeMessage: 'ASB Platform yönetim paneline giriş yapın.',
          properties: {
            email: 'E-posta',
            password: 'Şifre',
          },
          loginButton: 'Giriş Yap',
        },
      },
      labels: {
        navigation: 'Navigasyon',
        pages: 'Sayfalar',
        selectedRecords: 'Seçilenler ({{selected}})',
        filters: 'Filtreler',
        adminVersion: 'Panel: {{version}}',
        appVersion: 'Uygulama: {{version}}',
        dashboard: 'Ana Sayfa',
        Kullanici: 'Kullanıcılar',
        Firma: 'Firmalar',
        Duyuru: 'Duyurular',
        Banner: 'Banner',
      },
      messages: {
        successfullyBulkDeleted: '{{count}} kayıt silindi',
        successfullyBulkDeleted_plural: '{{count}} kayıt silindi',
        successfullyDeleted: 'Kayıt silindi',
        successfullyCreated: 'Kayıt oluşturuldu',
        successfullyUpdated: 'Kayıt güncellendi',
        thereWereValidationErrors: 'Doğrulama hataları var, alanları kontrol edin',
        forbiddenError: 'Bu işlem için yetkiniz yok',
        anyForbiddenError: 'Bu işlem için yetkiniz yok',
        errorFetchingRecord: 'Kayıt getirilemedi',
        errorFetchingRecords: 'Kayıtlar getirilemedi',
        bulkDeleteError: 'Kayıtlar silinirken bir hata oluştu',
        noRecordsInResource: 'Bu bölümde kayıt yok',
        noRecords: 'Kayıt yok',
        noRecordsSelected: 'Hiç kayıt seçmediniz',
        pickSomeFirst: 'Önce en az bir kayıt seçin',
        pickSomeFirstToRemove: 'Silmek için önce kayıt seçmelisiniz',
        theseRecordsWillBeRemoved: 'Şu kayıt silinecek',
        theseRecordsWillBeRemoved_plural: 'Şu kayıtlar silinecek',
        confirmDelete: 'Bu kaydı silmek istediğinize emin misiniz?',
        invalidCredentials: 'E-posta veya şifre hatalı, ya da bu hesabın admin yetkisi yok',
        seeConsoleForMore: 'Ayrıntılar için tarayıcı konsoluna bakın...',
        // Ana ekrandaki varsayılan AdminJS "onboarding" kartları — bu bir
        // demo/tanıtım paneli değil, gerçek bir yönetim aracı olduğu için
        // Türkçeleştirildi (silinmedi, sadece dil değişti).
        welcomeOnBoard_title: 'Hoş Geldiniz',
        welcomeOnBoard_subtitle: 'ASB Platform yönetim paneline hoş geldiniz.',
        addingResources_title: 'Kaynak Ekleme',
        addingResources_subtitle: 'Kenar çubuğuna yeni kaynak nasıl eklenir',
        customizeResources_title: 'Kaynakları Özelleştirme',
        customizeResources_subtitle: 'Davranış, alan ve daha fazlasını tanımlayın',
        customizeActions_title: 'Aksiyonları Özelleştirme',
        customizeActions_subtitle: 'Mevcut aksiyonları değiştirin veya yenisini ekleyin',
        writeOwnComponents_title: 'Bileşen Yazma',
        writeOwnComponents_subtitle: "AdminJS'in görünümünü nasıl değiştirirsiniz",
        customDashboard_title: 'Özel Ana Sayfa',
        customDashboard_subtitle: "AdminJS'in ana ekranını nasıl özelleştirirsiniz",
        roleBasedAccess_title: 'Rol Bazlı Erişim Kontrolü',
        roleBasedAccess_subtitle: 'AdminJS kullanıcıları için erişim izinlerini tanımlayın',
        community_title: 'Discord topluluğuna katılın',
        community_subtitle: "AdminJS'in yaratıcılarıyla ve diğer kullanıcılarla konuşun",
        foundBug_title: 'Hata mı buldunuz? İyileştirme mi gerekiyor?',
        foundBug_subtitle: "GitHub deposunda bir issue açın",
        needMoreSolutions_title: 'Daha gelişmiş çözümlere mi ihtiyacınız var?',
        needMoreSolutions_subtitle: 'Size özel UX/UI tasarımı ve yazılım çözümleri sunuyoruz',
      },
      properties: {
        id: 'ID',
        length: 'Uzunluk',
        from: 'Başlangıç',
        to: 'Bitiş',
      },
      resources: {
        Kullanici: {
          properties: {
            email: 'E-posta',
            telefon: 'Telefon',
            ad: 'Ad',
            soyad: 'Soyad',
            firma: 'Firma',
            rol: 'Rol',
            epostaDogrulandi: 'E-posta Doğrulandı',
            olusturmaTarihi: 'Oluşturma Tarihi',
            guncellemeTarihi: 'Güncelleme Tarihi',
          },
        },
        Firma: {
          properties: {
            ad: 'Firma Adı',
            logoUrl: 'Logo URL',
            sektor: 'Sektör',
            adres: 'Adres',
            telefon: 'Telefon',
            eposta: 'E-posta',
            onayDurumu: 'Onay Durumu',
            aktif: 'Aktif',
            webAdres: 'Web Adresi',
            kurulusTarihi: 'Kuruluş Tarihi',
            personelSayisi: 'Personel Sayısı',
            olusturmaTarihi: 'Oluşturma Tarihi',
            guncellemeTarihi: 'Güncelleme Tarihi',
          },
          actions: {
            onayla: 'Onayla',
            reddet: 'Reddet',
          },
        },
        Duyuru: {
          properties: {
            baslik: 'Başlık',
            icerik: 'İçerik',
            kategori: 'Kategori',
            yayinTarihi: 'Yayın Tarihi',
            olusturanKullanici: 'Oluşturan Kullanıcı',
          },
        },
        Banner: {
          properties: {
            gorselUrl: 'Görsel URL',
            linkUrl: 'Link URL',
            sira: 'Sıra',
            aktif: 'Aktif',
          },
        },
      },
    },
  },
};
