import { readFile } from 'fs/promises';
import type { ActionContext, ResourceWithOptions } from 'adminjs';
import type { PrismaService } from '../shared/infrastructure/prisma.service';
import type { FileStoragePort } from '../shared/infrastructure/file-storage/file-storage.port';

// `@adminjs/prisma` saf ESM paket, bu proje CommonJS derlendiği için üstte
// `import { getModelByName } from '@adminjs/prisma'` YAZILAMAZ — derleme
// `require()`e çevirir ve `ERR_REQUIRE_ESM` ile çöker. Fonksiyon dışarıdan
// (admin-panel.module.ts'teki dinamik `import()`den) parametre olarak
// geliyor — bkz. o dosyadaki not.
type GetModelByName = (name: string) => unknown;

// formidable v1 (express-formidable'ın bağımlılığı) dosya şekli — tip
// bildirimi projeye eklenmedi, tek kullanım yeri burası.
interface FormidableDosya {
  path: string;
  name: string;
  type: string;
  size: number;
}

/**
 * AdminJS'in yönetebileceği kaynaklar. 18.08.2026'da Berzan'ın isteğiyle
 * genişletildi: "admin her şeye yetkinse admin panelinde her şey olmak
 * zorunda" — önceden sadece kendi API'leri üzerinden yönetilen İş Ortağı,
 * Palet, İkinci El Pazar ve rol-yetki eşleşmeleri de artık burada, TAM CRUD
 * (Cookzone/Acil Durum/Palet Tesisi'nin uygulama içi kendi yönetim ekranları
 * ayrıca duruyor — bunlar birbirini DIŞLAMIYOR, admin ikisinden de erişebilir).
 *
 * Görsel/logo alanları (Firma.logoUrl, Banner.gorselUrl, IsOrtagi.logoUrl,
 * Palet.gorselUrl) artık düz URL metin kutusu DEĞİL — `gorselYuklemeAksiyonu`
 * ile gerçek dosya yükleme (bkz. admin-components/gorsel-yukleme-formu.jsx).
 */
export function adminKaynaklariniOlustur(
  prisma: PrismaService,
  getModelByName: GetModelByName,
  fileStorage: FileStoragePort,
  gorselYuklemeBileseni: string,
): ResourceWithOptions[] {
  return [
    kullaniciKaynagi(prisma, getModelByName),
    rolYetkiKaynagi(prisma, getModelByName),
    firmaKaynagi(prisma, getModelByName, fileStorage, gorselYuklemeBileseni),
    duyuruKaynagi(prisma, getModelByName),
    bannerKaynagi(prisma, getModelByName, fileStorage, gorselYuklemeBileseni),
    acilDurumBildirimiKaynagi(prisma, getModelByName),
    isOrtagiKaynagi(prisma, getModelByName, fileStorage, gorselYuklemeBileseni),
    paletKaynagi(prisma, getModelByName, fileStorage, gorselYuklemeBileseni),
    ikinciElIlaniKaynagi(prisma, getModelByName),
  ];
}

/**
 * Herhangi bir Prisma modelinde tek bir "...Url" alanına gerçek dosya
 * yükleyen ortak record action. `@adminjs/upload` eklentisi ayrı key/bucket/
 * mimeType alanları gerektirdiği için (mevcut şemayla uyuşmuyor) bilerek
 * kullanılmadı — bunun yerine AdminJS'in @adminjs/express içine gömülü
 * formidable multipart ayrıştırması (bkz. buildRouter.ts) ile bu action'a
 * POST edilen dosya `request.payload.gorsel` olarak karşılanıp mevcut
 * `FileStoragePort.upload()` ile (uygulamanın geri kalanıyla AYNI mekanizma)
 * kaydediliyor.
 */
function gorselYuklemeAksiyonu(
  prismaDelege: { update: (args: { where: { id: string }; data: Record<string, string> }) => Promise<unknown> },
  alanAdi: string,
  fileStorage: FileStoragePort,
  gorselYuklemeBileseni: string,
) {
  return {
    actionType: 'record' as const,
    icon: 'Upload',
    component: gorselYuklemeBileseni,
    handler: async (
      request: { method: string; payload?: Record<string, unknown> },
      _response: unknown,
      context: ActionContext,
    ) => {
      const { record, resource, currentAdmin } = context;
      if (!record) throw new Error('Kayıt bulunamadı');

      if (request.method === 'post') {
        const dosya = request.payload?.gorsel as FormidableDosya | undefined;
        if (dosya?.path) {
          const arabellek = await readFile(dosya.path);
          const url = await fileStorage.upload(dosya.name, arabellek);
          await prismaDelege.update({ where: { id: record.params.id }, data: { [alanAdi]: url } });
        }
      }

      const guncelKayit = await resource.findOne(record.params.id);
      return { record: guncelKayit!.toJSON(currentAdmin) };
    },
  };
}

function kullaniciKaynagi(prisma: PrismaService, getModelByName: GetModelByName): ResourceWithOptions {
  return {
    resource: { model: getModelByName('Kullanici'), client: prisma },
    options: {
      id: 'Kullanici',
      navigation: { name: 'Kullanıcı Yönetimi', icon: 'Users' },
      titleProperty: 'email',
      // DİKKAT: Prisma DMMF, bir ilişkiyi taşıyan skaler FK alanını (`firmaId`)
      // `isReadOnly: true` işaretleyip @adminjs/prisma'nın özellik listesinden
      // tamamen düşürüyor — AdminJS'in gördüğü gerçek alan adı ilişkinin
      // kendisi (`firma`), `firmaId` DEĞİL. Yanlış adı kullanmak sessizce
      // hiçbir şey yapmıyor (filtre/gösterim boş kalıyor, hata da vermiyor).
      listProperties: ['email', 'ad', 'soyad', 'rol', 'firma', 'epostaDogrulandi'],
      editProperties: ['email', 'ad', 'soyad', 'telefon', 'rol', 'firma', 'epostaDogrulandi'],
      showProperties: [
        'id',
        'email',
        'ad',
        'soyad',
        'telefon',
        'rol',
        'firma',
        'epostaDogrulandi',
        'olusturmaTarihi',
        'guncellemeTarihi',
      ],
      filterProperties: ['email', 'rol', 'firma', 'epostaDogrulandi'],
      properties: {
        // Hash asla panelde görünmez/düzenlenmez — şifre sıfırlama bilerek
        // kapsam dışı bırakıldı (bkz. modül planı), yanlışlıkla düz metin
        // yazılıp hash'in bozulmasının önü böyle kesiliyor.
        sifreHash: { isVisible: false },
      },
    },
  };
}

/**
 * `KullaniciRolu`ya hangi `Yetki`nin (ör. ikinci_el_yonet) tanımlı olduğunu
 * yönetir — "departman" diye ayrı bir varlık YOK (18.08.2026, Berzan'ın
 * kararı), sadece mevcut rollere ince taneli izin ekleme/çıkarma. Yeni bir
 * role yeni bir izin vermek istendiğinde admin buradan yeni bir satır ekler.
 */
function rolYetkiKaynagi(prisma: PrismaService, getModelByName: GetModelByName): ResourceWithOptions {
  return {
    resource: { model: getModelByName('RolYetki'), client: prisma },
    options: {
      id: 'RolYetki',
      navigation: { name: 'Kullanıcı Yönetimi', icon: 'Key' },
      titleProperty: 'yetki',
      listProperties: ['rol', 'yetki'],
      editProperties: ['rol', 'yetki'],
      showProperties: ['id', 'rol', 'yetki'],
      filterProperties: ['rol', 'yetki'],
    },
  };
}

function firmaKaynagi(
  prisma: PrismaService,
  getModelByName: GetModelByName,
  fileStorage: FileStoragePort,
  gorselYuklemeBileseni: string,
): ResourceWithOptions {
  return {
    resource: { model: getModelByName('Firma'), client: prisma },
    options: {
      id: 'Firma',
      navigation: { name: 'Firma Yönetimi', icon: 'Briefcase' },
      titleProperty: 'ad',
      sort: { sortBy: 'onayDurumu', direction: 'asc' },
      listProperties: ['ad', 'sektor', 'onayDurumu', 'aktif', 'telefon', 'eposta'],
      editProperties: [
        'ad',
        'logoUrl',
        'sektor',
        'adres',
        'telefon',
        'eposta',
        'webAdres',
        'kurulusTarihi',
        'personelSayisi',
        'onayDurumu',
        'aktif',
      ],
      showProperties: [
        'id',
        'ad',
        'logoUrl',
        'sektor',
        'adres',
        'telefon',
        'eposta',
        'webAdres',
        'kurulusTarihi',
        'personelSayisi',
        'onayDurumu',
        'aktif',
        'olusturmaTarihi',
        'guncellemeTarihi',
      ],
      filterProperties: ['ad', 'sektor', 'onayDurumu', 'aktif'],
      properties: {
        // Elle URL yapıştırma kaldırılmadı (esneklik için) ama artık asıl
        // yol "Görsel Yükle" aksiyonu — logoUrl edit formunda salt-okunur
        // gösterilmiyor, sadece show'da bilgi amaçlı.
        logoUrl: { isVisible: { list: false, filter: false, edit: true, show: true } },
      },
      actions: {
        // BR-1: yeni kayıt backend'de zaten 'beklemede' başlıyor (Prisma
        // @default) — burada tekrar zorlamaya gerek yok, aynı domain kuralı
        // AdminJS'ten oluşturulan kayıt için de geçerli.
        //
        // onayla/reddet: tek tıkla onay durumu değişimi için — onayDurumu
        // alanı zaten edit formunda da açık (aşırı esneklik istendi), ama bu
        // iki buton en sık yapılan işlemi (onay kuyruğunu boşaltmayı) tek
        // tıka indiriyor. component: false → ayrı bir ekran açmadan hemen
        // çalışır, sayfa kendini yeniler.
        onayla: {
          actionType: 'record',
          icon: 'CheckCircle',
          variant: 'success',
          component: false,
          isVisible: (context) => context.record?.params.onayDurumu !== 'onaylandi',
          handler: async (request, response, context) => {
            const { record, resource, currentAdmin } = context;
            if (!record) throw new Error('Kayıt bulunamadı');
            await prisma.firma.update({
              where: { id: record.params.id },
              data: { onayDurumu: 'onaylandi' },
            });
            const guncelKayit = await resource.findOne(record.params.id);
            return {
              record: guncelKayit!.toJSON(currentAdmin),
              notice: { message: 'Firma onaylandı.', type: 'success' },
            };
          },
        },
        reddet: {
          actionType: 'record',
          icon: 'XCircle',
          variant: 'danger',
          component: false,
          guard: 'confirmDelete',
          isVisible: (context) => context.record?.params.onayDurumu !== 'reddedildi',
          handler: async (request, response, context) => {
            const { record, resource, currentAdmin } = context;
            if (!record) throw new Error('Kayıt bulunamadı');
            await prisma.firma.update({
              where: { id: record.params.id },
              data: { onayDurumu: 'reddedildi' },
            });
            const guncelKayit = await resource.findOne(record.params.id);
            return {
              record: guncelKayit!.toJSON(currentAdmin),
              notice: { message: 'Firma reddedildi.', type: 'success' },
            };
          },
        },
        gorselYukle: gorselYuklemeAksiyonu(prisma.firma, 'logoUrl', fileStorage, gorselYuklemeBileseni),
      },
    },
  };
}

function duyuruKaynagi(prisma: PrismaService, getModelByName: GetModelByName): ResourceWithOptions {
  return {
    resource: { model: getModelByName('Duyuru'), client: prisma },
    options: {
      id: 'Duyuru',
      navigation: { name: 'İçerik Yönetimi', icon: 'Bell' },
      titleProperty: 'baslik',
      sort: { sortBy: 'yayinTarihi', direction: 'desc' },
      listProperties: ['baslik', 'kategori', 'yayinTarihi'],
      editProperties: ['baslik', 'icerik', 'kategori', 'yayinTarihi'],
      // `olusturanKullaniciId` DEĞİL `olusturanKullanici` — bkz. kullaniciKaynagi'ndaki not
      // (Prisma DMMF ilişkiyi taşıyan FK skalerini read-only sayıp gizliyor).
      showProperties: ['id', 'baslik', 'icerik', 'kategori', 'yayinTarihi', 'olusturanKullanici'],
      filterProperties: ['baslik', 'kategori', 'yayinTarihi'],
      properties: {
        icerik: { type: 'textarea' },
        // Kim oluşturduğu bilgisi manuel seçilmiyor — panelde oturum açmış
        // admin otomatik atanıyor (bkz. actions.new.before). Bu yüzden
        // create/edit formunda hiç görünmüyor, sadece show'da bilgi amaçlı var.
        olusturanKullanici: { isVisible: { list: false, filter: false, edit: false, show: true } },
      },
      actions: {
        new: {
          before: async (request, context) => {
            request.payload = {
              ...request.payload,
              // Property adı `olusturanKullanici` (ilişki adı) — `olusturanKullaniciId`
              // yazılırsa @adminjs/prisma bu alanı tanımadığı için sessizce
              // yok sayar ve Prisma "Argument olusturanKullanici is missing" ile patlar
              // (elle doğrulandı).
              olusturanKullanici: context.currentAdmin?.id,
            };
            return request;
          },
        },
      },
    },
  };
}

function bannerKaynagi(
  prisma: PrismaService,
  getModelByName: GetModelByName,
  fileStorage: FileStoragePort,
  gorselYuklemeBileseni: string,
): ResourceWithOptions {
  return {
    resource: { model: getModelByName('Banner'), client: prisma },
    options: {
      id: 'Banner',
      navigation: { name: 'İçerik Yönetimi', icon: 'Image' },
      titleProperty: 'gorselUrl',
      sort: { sortBy: 'sira', direction: 'asc' },
      listProperties: ['gorselUrl', 'linkUrl', 'sira', 'aktif'],
      editProperties: ['gorselUrl', 'linkUrl', 'sira', 'aktif'],
      showProperties: ['id', 'gorselUrl', 'linkUrl', 'sira', 'aktif'],
      filterProperties: ['aktif'],
      actions: {
        gorselYukle: gorselYuklemeAksiyonu(prisma.banner, 'gorselUrl', fileStorage, gorselYuklemeBileseni),
      },
    },
  };
}

function acilDurumBildirimiKaynagi(prisma: PrismaService, getModelByName: GetModelByName): ResourceWithOptions {
  return {
    resource: { model: getModelByName('AcilDurumBildirimi'), client: prisma },
    options: {
      id: 'AcilDurumBildirimi',
      navigation: { name: 'Acil Durum Bildirimleri', icon: 'AlertTriangle' },
      titleProperty: 'aciklama',
      sort: { sortBy: 'olusturmaTarihi', direction: 'desc' },
      // `kullaniciId` DEĞİL `kullanici` (ilişki adı) — kullaniciKaynagi'ndaki
      // notla aynı sebep.
      listProperties: ['tur', 'aciklama', 'durum', 'kullanici', 'olusturmaTarihi'],
      editProperties: ['durum'],
      showProperties: ['id', 'tur', 'aciklama', 'durum', 'kullanici', 'olusturmaTarihi'],
      filterProperties: ['tur', 'durum'],
      actions: {
        // Sadece durum güncellenebilir — admin bir bildirimi ELLE "yangin"dan
        // "kaza"ya çeviremez, bu anlamsız olurdu (bkz. edit/new'i kapatma).
        new: { isAccessible: false },
        edit: { isAccessible: false },
        incelemeyeAl: {
          actionType: 'record',
          icon: 'Eye',
          variant: 'primary',
          component: false,
          isVisible: (context) => context.record?.params.durum === 'yeni',
          handler: async (request, response, context) => {
            const { record, resource, currentAdmin } = context;
            if (!record) throw new Error('Kayıt bulunamadı');
            await prisma.acilDurumBildirimi.update({
              where: { id: record.params.id },
              data: { durum: 'inceleniyor' },
            });
            const guncelKayit = await resource.findOne(record.params.id);
            return {
              record: guncelKayit!.toJSON(currentAdmin),
              notice: { message: 'Bildirim inceleniyor olarak işaretlendi.', type: 'success' },
            };
          },
        },
        kapat: {
          actionType: 'record',
          icon: 'CheckCircle',
          variant: 'success',
          component: false,
          isVisible: (context) => context.record?.params.durum !== 'kapatildi',
          handler: async (request, response, context) => {
            const { record, resource, currentAdmin } = context;
            if (!record) throw new Error('Kayıt bulunamadı');
            await prisma.acilDurumBildirimi.update({
              where: { id: record.params.id },
              data: { durum: 'kapatildi' },
            });
            const guncelKayit = await resource.findOne(record.params.id);
            return {
              record: guncelKayit!.toJSON(currentAdmin),
              notice: { message: 'Bildirim kapatıldı.', type: 'success' },
            };
          },
        },
      },
    },
  };
}

/** Daha önce hiç AdminJS kaynağı yoktu (sadece herkese açık GET ucu vardı) —
 * 18.08.2026, Berzan'ın "admin her şeye yetkinse panelde her şey olmalı"
 * kararıyla tam CRUD + görsel yükleme eklendi. */
function isOrtagiKaynagi(
  prisma: PrismaService,
  getModelByName: GetModelByName,
  fileStorage: FileStoragePort,
  gorselYuklemeBileseni: string,
): ResourceWithOptions {
  return {
    resource: { model: getModelByName('IsOrtagi'), client: prisma },
    options: {
      id: 'IsOrtagi',
      navigation: { name: 'İçerik Yönetimi', icon: 'Handshake' },
      titleProperty: 'ad',
      listProperties: ['ad', 'kategori', 'logoUrl'],
      editProperties: ['ad', 'kategori', 'logoUrl'],
      showProperties: ['id', 'ad', 'kategori', 'logoUrl'],
      filterProperties: ['ad', 'kategori'],
      actions: {
        gorselYukle: gorselYuklemeAksiyonu(prisma.isOrtagi, 'logoUrl', fileStorage, gorselYuklemeBileseni),
      },
    },
  };
}

/** Palet Tesisi'nin palet çeşitleri — uygulama içinde palet_tesisi_yetkilisi
 * zaten yönetebiliyor (bkz. PaletTesisiController), burada AYRICA admin
 * paneline eklendi (18.08.2026, Berzan: "admin görebilmeli/düzenleyebilmeli"
 * — ikisi birbirini dışlamıyor, aynı tabloya iki erişim yolu). */
function paletKaynagi(
  prisma: PrismaService,
  getModelByName: GetModelByName,
  fileStorage: FileStoragePort,
  gorselYuklemeBileseni: string,
): ResourceWithOptions {
  return {
    resource: { model: getModelByName('Palet'), client: prisma },
    options: {
      id: 'Palet',
      navigation: { name: 'Palet Tesisi', icon: 'Package' },
      titleProperty: 'ad',
      sort: { sortBy: 'sira', direction: 'asc' },
      listProperties: ['ad', 'olcu', 'aktif', 'sira'],
      editProperties: ['ad', 'aciklama', 'olcu', 'aktif', 'sira'],
      showProperties: ['id', 'ad', 'aciklama', 'olcu', 'gorselUrl', 'aktif', 'sira'],
      filterProperties: ['aktif'],
      properties: {
        aciklama: { type: 'textarea' },
      },
      actions: {
        gorselYukle: gorselYuklemeAksiyonu(prisma.palet, 'gorselUrl', fileStorage, gorselYuklemeBileseni),
      },
    },
  };
}

/** İkinci El Pazar ilanları — ilan girme izni artık RolYetki üzerinden (bkz.
 * rolYetkiKaynagi), ama admin panelden ilan durumunu (satıldı/pasif) ve "öne
 * çıkan" bayrağını (Ana Sayfa entegrasyonu) tek noktadan yönetebilmeli.
 * Fotoğraflar (`fotografUrls`) ilan oluşturulurken uygulamadan yükleniyor —
 * admin panelinde sadece görüntülenir, panelden yeni fotoğraf eklenmiyor
 * (dizi alanı, tekil `gorselYuklemeAksiyonu` deseni buraya uymuyor). */
function ikinciElIlaniKaynagi(prisma: PrismaService, getModelByName: GetModelByName): ResourceWithOptions {
  return {
    resource: { model: getModelByName('IkinciElIlani'), client: prisma },
    options: {
      id: 'IkinciElIlani',
      navigation: { name: 'İkinci El Pazar', icon: 'ShoppingBag' },
      titleProperty: 'baslik',
      sort: { sortBy: 'olusturmaTarihi', direction: 'desc' },
      listProperties: ['baslik', 'kategori', 'fiyat', 'durum', 'oneCikan', 'kullanici'],
      editProperties: ['durum', 'oneCikan'],
      showProperties: [
        'id',
        'baslik',
        'aciklama',
        'fiyat',
        'kategori',
        'urunDurumu',
        'iletisimTelefonu',
        'fotografUrls',
        'durum',
        'oneCikan',
        'kullanici',
        'olusturmaTarihi',
      ],
      filterProperties: ['baslik', 'kategori', 'durum', 'oneCikan'],
      actions: {
        // İlan oluşturma sadece uygulamadan (ikinci_el_yonet yetkisiyle) —
        // admin panelinden elle sahte ilan girilmesi anlamsız.
        new: { isAccessible: false },
      },
    },
  };
}
