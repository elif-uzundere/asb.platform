import type { ResourceWithOptions } from 'adminjs';
import type { PrismaService } from '../shared/infrastructure/prisma.service';

// `@adminjs/prisma` saf ESM paket, bu proje CommonJS derlendiği için üstte
// `import { getModelByName } from '@adminjs/prisma'` YAZILAMAZ — derleme
// `require()`e çevirir ve `ERR_REQUIRE_ESM` ile çöker. Fonksiyon dışarıdan
// (admin-panel.module.ts'teki dinamik `import()`den) parametre olarak
// geliyor — bkz. o dosyadaki not.
type GetModelByName = (name: string) => unknown;

/**
 * AdminJS'in yönetebileceği kaynaklar. Kapsam bilerek sınırlı tutuldu (bkz.
 * kullanıcıyla konuşulan admin paneli kapsamı): Firma onay/CRUD, Duyuru CRUD,
 * Banner CRUD, Kullanıcı/rol yönetimi, Acil Durum Bildirimleri (13.08.2026 —
 * ayrı bir "acil_durum_yetkilisi" rolü/Flutter ekranı yerine bilinçli olarak
 * burada, izlencede böyle bir rol hiç planlanmamıştı). Diğer tablolar
 * (iş ilanı, ikinci el, cookzone, palet tesisi, bölge noktası...) bilerek
 * burada YOK — kendi API'leri üzerinden yönetiliyor. Yeni bir kaynak
 * eklemek istenirse buraya bir öğe daha eklemek yeterli.
 */
export function adminKaynaklariniOlustur(
  prisma: PrismaService,
  getModelByName: GetModelByName,
): ResourceWithOptions[] {
  return [
    kullaniciKaynagi(prisma, getModelByName),
    firmaKaynagi(prisma, getModelByName),
    duyuruKaynagi(prisma, getModelByName),
    bannerKaynagi(prisma, getModelByName),
    acilDurumBildirimiKaynagi(prisma, getModelByName),
  ];
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

function firmaKaynagi(prisma: PrismaService, getModelByName: GetModelByName): ResourceWithOptions {
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

function bannerKaynagi(prisma: PrismaService, getModelByName: GetModelByName): ResourceWithOptions {
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
