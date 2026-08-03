import { Injectable } from '@nestjs/common';

// Bu dosya `@adminjs/express`/Express'in dahili (tip bildirimi olmayan ya da
// ESM olduğu için statik import edilemeyen) nesneleriyle çalışıyor — ham
// `any` kaçınılmaz, tipleri taklit etmek gerçek güvenliği artırmadan
// gürültü ekler.
/* eslint-disable @typescript-eslint/no-explicit-any */

/**
 * @adminjs/nestjs'in yerleşik ExpressLoader'ı yerine kullanılıyor.
 *
 * NEDEN: Kütüphanenin kendi loader'ı `register()` sonunda `reorderRoutes()`
 * çağırıp Express'in iç route yığınını (`app.router.stack`) düzenlemeye
 * çalışıyor — ama `app.router` Express 3'e ait, Express 4'te KALDIRILDI
 * (erişilince "'app.router' is deprecated!" hatasıyla çöküyor). Bu, aşağıda
 * `app._router.stack` (Express 4'ün gerçek iç karşılığı — belgelenmemiş ama
 * kararlı, Express ekosisteminde bu amaçla yaygın kullanılıyor) ile yeniden
 * yazıldı.
 *
 * Bu reorder adımı KOZMETİK DEĞİL: Nest'in `NestFactory.create()` sırasında
 * otomatik eklediği global body-parser (json/urlencoded), admin router'ından
 * ÖNCE tüm route'lara bağlanıyor. AdminJS'in giriş formu kendi body-parser'ını
 * bekliyor; Nest'in body-parser'ı isteği önce tüketirse AdminJS
 * `WrongArgumentError: You probably used old 'body-parser' middleware...`
 * ile patlıyor (elle doğrulandı — reorder olmadan giriş 500 veriyordu).
 * Çözüm: admin router'ını + json/urlencoded parser katmanlarını route
 * yığınında en başa (cors/expressInit'ten hemen sonra) taşımak — böylece
 * admin router kendi body'sini önce, Nest'in global parser'ı görmeden işliyor.
 */
@Injectable()
export class AdminExpressYukleyici {
  async register(admin: any, httpAdapter: { getInstance: () => any }, options: any): Promise<void> {
    const app = httpAdapter.getInstance();
    const { default: adminJsExpressjs } = await import('@adminjs/express');

    const router = options.auth
      ? adminJsExpressjs.buildAuthenticatedRouter(
          admin,
          options.auth,
          undefined,
          options.sessionOptions,
          options.formidableOptions,
        )
      : adminJsExpressjs.buildRouter(admin, undefined, options.formidableOptions);

    app.use(options.adminJsOptions.rootPath, function admin(req: any, res: any, next: any) {
      return router(req, res, next);
    });

    this.routeSiraliyorum(app);
  }

  private routeSiraliyorum(app: any): void {
    const stack = app?._router?.stack;
    if (!stack) return;

    const cikar = (isim: string) => {
      const index = stack.findIndex((layer: any) => layer.name === isim);
      return index >= 0 ? stack.splice(index, 1) : [];
    };

    const jsonParser = cikar('jsonParser');
    const urlencodedParser = cikar('urlencodedParser');
    const adminLayer = cikar('admin');

    const corsIndex = stack.findIndex((layer: any) => layer.name === 'corsMiddleware');
    const expressInitIndex = stack.findIndex((layer: any) => layer.name === 'expressInit');
    const baslangicIndex = (corsIndex >= 0 ? corsIndex : expressInitIndex) + 1;

    stack.splice(baslangicIndex, 0, ...adminLayer, ...jsonParser, ...urlencodedParser);
  }
}
