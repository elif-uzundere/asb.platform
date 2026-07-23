# ASB Platform

Avrupa Serbest Bölgesi hizmet platformu — monorepo (npm workspaces).

## Paketler

- `packages/shared-types` — Backend ↔ Frontend arasında paylaşılan TypeScript tipleri
- `packages/backend` — NestJS API (`/api/v1/...`)
- `packages/mobile` — Expo (React Native + Web) uygulaması

## Kurulum

```bash
npm install
docker compose up -d
npm run build --workspace=@asb/shared-types
npx prisma migrate dev --schema packages/backend/prisma/schema.prisma
npm run dev:backend
npm run dev:mobile
```

Detaylı mimari ve adım planı için `docs/izlence-typescript-nestjs(1).md`, veri modeli için `docs/teknikPlan.md`.
