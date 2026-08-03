import { tmpdir } from 'os';
import { join } from 'path';
import { DynamicModule, Module } from '@nestjs/common';
import type { CurrentAdmin } from 'adminjs';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../shared/infrastructure/prisma.service';
import { adminKaynaklariniOlustur } from './admin-kaynaklari';
import { adminYerellestirme } from './admin-yerellestirme';
import { AdminExpressYukleyici } from './admin-express-yukleyici';

// AdminJS geliştirme modunda kendi canlı-bundle izleyicisini (rollup, react
// bileşenleri için) çalıştırıyor ve çıktısını varsayılan olarak proje
// kökündeki `.adminjs/` klasörüne yazıyor. Bu, `nest start --watch`'ın kendi
// dosya izleyicisiyle çakışıp SONSUZ yeniden başlatma döngüsüne yol açtı
// (elle doğrulandı — `.adminjs/bundle.js` her yazıldığında "File change
// detected" tetikleniyordu). Çözüm: çıktıyı proje ağacının tamamen dışına,
// OS'un geçici klasörüne yönlendirmek. `adminjs` paketi bu değişkeni kendi
// modülü ilk import edildiğinde okuyor, bu yüzden aşağıdaki dinamik
// `import('adminjs')`den ÖNCE atanmış olmak zorunda.
process.env.ADMIN_JS_TMP_DIR ??= join(tmpdir(), 'asb-platform-adminjs');

/**
 * AdminJS panelini `/admin` altında sunar. Kimlik doğrulama JWT/Bearer token
 * DEĞİL — panel tarayıcıdan kullanılan ayrı bir arayüz olduğu için AdminJS'in
 * kendi session-cookie tabanlı login ekranını kullanıyor. Ama admin hesabı
 * AYRI bir tablo/şifre DEĞİL — ana `kullanici` tablosundaki `rol = admin`
 * kaydına, aynı bcrypt hash'e karşı doğrulanıyor. Yani platformda tek bir
 * admin kimliği var, iki farklı giriş kapısından (mobil/web JWT + bu panel)
 * erişiliyor.
 *
 * NEDEN `imports: [adminModuluAsync()]` (statik `import` değil): `adminjs`,
 * `@adminjs/nestjs` ve `@adminjs/prisma` saf ESM paketler (`@adminjs/nestjs`
 * hiç `require` koşulu bile sunmuyor). Bu backend CommonJS derlendiği için
 * üstte `import { AdminModule } from '@adminjs/nestjs'` yazmak derleme
 * zamanında `require()`e çevrilir ve `ERR_PACKAGE_PATH_NOT_EXPORTED` /
 * `ERR_REQUIRE_ESM` ile process'i çökertir. NestJS'in `imports` dizisi
 * `Promise<DynamicModule>` kabul ediyor (bkz. `ModuleMetadata` tipi) — bu
 * sayede paketler `await import(...)` ile ÇALIŞMA ZAMANINDA (derleme değil)
 * yükleniyor, tüm backend'i ESM'e çevirmeye gerek kalmıyor.
 */
@Module({
  imports: [adminModuluAsync()],
})
export class AdminPanelModule {}

async function adminModuluAsync(): Promise<DynamicModule> {
  const { AdminModule } = await import('@adminjs/nestjs');
  const { default: AdminJS, ComponentLoader } = await import('adminjs');
  const { Database, Resource, getModelByName } = await import('@adminjs/prisma');

  AdminJS.registerAdapter({ Database, Resource });

  // Bileşen dosyası bilerek `src/` DIŞINDA (`admin-components/`) — JSX/React
  // içerdiği için backend'in kendi tsc/eslint'ine YAKALANMAMASI gerekiyor
  // (bkz. gosterge-paneli.jsx başındaki not). Mutlak yol veriliyor ki
  // ComponentLoader'ın çağıran-dosyaya göre yol çözümlemesi devreye girmesin.
  const componentLoader = new ComponentLoader();
  const gostergePaneliBileseni = componentLoader.add(
    'GostergePaneli',
    join(__dirname, '..', '..', 'admin-components', 'gosterge-paneli.jsx'),
  );

  return AdminModule.createAdminAsync({
    customLoader: AdminExpressYukleyici,
    inject: [PrismaService],
    useFactory: (prisma: PrismaService) => ({
      adminJsOptions: {
        rootPath: '/admin',
        componentLoader,
        branding: {
          companyName: 'ASB Platform',
          withMadeWithLove: false,
        },
        locale: adminYerellestirme,
        resources: adminKaynaklariniOlustur(prisma, getModelByName),
        // Varsayılan AdminJS ana sayfası "AdminJS nasıl kurulur/özelleştirilir"
        // türünden geliştirici tanıtım kartları gösteriyor — gerçek bir
        // yönetim panelinde anlamsız. Yerine gerçek verilerle (bekleyen firma
        // onayı vb.) özel bir özet ekranı kondu.
        dashboard: {
          component: gostergePaneliBileseni,
          handler: async () => {
            const [bekleyenFirma, toplamFirma, toplamDuyuru, toplamKullanici, aktifBanner] = await Promise.all([
              prisma.firma.count({ where: { onayDurumu: 'beklemede' } }),
              prisma.firma.count(),
              prisma.duyuru.count(),
              prisma.kullanici.count(),
              prisma.banner.count({ where: { aktif: true } }),
            ]);
            return { bekleyenFirma, toplamFirma, toplamDuyuru, toplamKullanici, aktifBanner };
          },
        },
      },
      auth: {
        cookieName: 'asb-admin',
        cookiePassword: adminPanelSecret(),
        authenticate: async (email: string, sifre: string): Promise<CurrentAdmin | null> => {
          const kullanici = await prisma.kullanici.findUnique({ where: { email } });
          if (!kullanici || kullanici.rol !== 'admin' || !kullanici.sifreHash) {
            return null;
          }
          const dogruMu = await bcrypt.compare(sifre, kullanici.sifreHash);
          if (!dogruMu) {
            return null;
          }
          return { id: kullanici.id, email: kullanici.email, title: 'Admin' };
        },
      },
      sessionOptions: {
        resave: false,
        saveUninitialized: false,
        secret: adminPanelSecret(),
      },
    }),
  });
}

/**
 * AdminJS `cookiePassword` için en az 32 karakter şartı koyuyor — .env'de
 * eksik bırakılırsa uygulama sessizce zayıf bir varsayılana düşmesin diye
 * burada patlıyoruz, `JWT_SECRET` gibi diğer sırlar için zaten uygulanan
 * "eksikse hemen görün" prensibiyle tutarlı.
 */
function adminPanelSecret(): string {
  const secret = process.env.ADMIN_PANEL_SECRET;
  if (!secret || secret.length < 32) {
    throw new Error('ADMIN_PANEL_SECRET .env dosyasında tanımlı ve en az 32 karakter olmalı.');
  }
  return secret;
}
