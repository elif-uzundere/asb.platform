# ASB Platform

Avrupa Serbest Bölgesi hizmet platformu — monorepo (npm workspaces).

## Paketler

- `packages/shared-types` — Backend ↔ Frontend arasında paylaşılan TypeScript tipleri. Dart bu paketi import edemediği için Flutter tarafında elle tutulan bir ayna var (`packages/app/lib/core/models/`) — bkz. `docs/CLAUDE.md` Alınan Kararlar
- `packages/backend` — NestJS API (`/api/v1/...`)
- `packages/app` — **Frontend.** Flutter (Dart) uygulaması, 27.07.2026'da mentör talimatıyla Expo/React Native'den geçildi

> Eski Expo kodu (`packages/mobile`) 28.07.2026'da **silindi** — her `npm install`'da gereksiz Expo/React Native bağımlılığı indiriliyordu. Geçiş karşılıkları ve tasarım sabitleri `docs/izlence-typescript-nestjs(1).md` → **Ek A**'da arşivli; kodun kendisi git geçmişinde duruyor.

## Kurulum

```bash
npm install
docker compose up -d
npm run build --workspace=@asb/shared-types

# .env dosyasını örnekten oluştur, ardından açıp kendi değerlerini gir
# (Mailtrap bilgileri, Google OAuth Client ID'leri — bkz. dosyanın içindeki
# yorumlar). DATABASE_URL/JWT_SECRET varsayılanları docker-compose.yml'daki
# geliştirme ortamıyla zaten uyumlu, değiştirmene gerek yok.
cp packages/backend/.env.example packages/backend/.env

npx prisma migrate dev --schema packages/backend/prisma/schema.prisma
npm run dev:backend

# Frontend (Flutter) — npm workspace değil, ayrı klasörden çalıştırılır:
cd packages/app
flutter run -d chrome
```

Flutter tarafında testler ve lint (`packages/app` içinden):

```bash
flutter analyze
flutter test
```

## Dokümanlar

| Ne arıyorsun | Dosya |
|---|---|
| **Yeni modül açıyorum, hangi dosya nereye?** | `docs/YENI-MODUL-REHBERI.md` |
| Değişmez mimari kuralları | `docs/CLAUDE.md` |
| Mimari felsefe, klasör yapısı, adım planı | `docs/izlence-typescript-nestjs(1).md` |
| Veri modeli, API ve response zarfı | `docs/teknikPlan.md` |
| Gereksinimler, user story'ler, kabul kriterleri | `docs/isterler.md` |
| Projeye yeni katılan için başlangıç | `docs/BASLANGIC-ELIF.md` |
