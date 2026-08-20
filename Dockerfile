# Prod imajı — üç aşamalı build.
#
# Flutter Web build çıktısını (packages/app/build/web) backend'in kendisi
# servis ediyor (bkz. main.ts, useStaticAssets — /uploads için zaten
# kullanılan aynı mekanizma). Ayrı bir nginx container yok, bu projenin
# ölçeğinde tek container yeterli.
#
# 3 aşama neden ayrı: backend'i derlemek Node ister, Flutter'ı derlemek
# ayrı ve çok daha büyük bir SDK ister. İkisi aynı imajda kalırsa final imaj
# gereksiz yere şişer. Çalışma imajı sadece derlenmiş çıktıları alır, Node
# build araçlarını ya da Flutter SDK'sını taşımaz.

# ── 1) shared-types + backend derleme ────────────────────────────────────
FROM node:20-bookworm-slim AS backend-build
WORKDIR /app

# `prisma generate` çalıştığı ortamdaki OpenSSL sürümüne göre hangi sorgu
# motoru binary'sini indireceğine karar veriyor. Burada openssl kurulu
# olmazsa yanlış bir sürüm (debian-openssl-1.1.x) için üretiyor, ama runtime
# imajında gerçekte openssl 3.0.x var. Sonuç: "could not locate the Query
# Engine for runtime debian-openssl-3.0.x" hatasıyla açılışta çöküyor.
# Runtime aşamasındakiyle aynı OpenSSL burada da kurulu olmalı ki
# `prisma generate` doğru motoru seçsin.
RUN apt-get update && apt-get install -y --no-install-recommends openssl \
    && rm -rf /var/lib/apt/lists/*

# Önce sadece package.json'lar kopyalanıyor. Bağımlılıklar değişmediği
# sürece Docker layer cache'i `npm ci`yi tekrar çalıştırmaz, kaynak kod her
# değiştiğinde tüm bağımlılıkları yeniden indirmemiş oluyoruz.
COPY package.json package-lock.json ./
COPY packages/shared-types/package.json packages/shared-types/package.json
COPY packages/backend/package.json packages/backend/package.json
RUN npm ci

COPY packages/shared-types packages/shared-types
COPY packages/backend packages/backend

RUN npm run build --workspace=@asb/shared-types
RUN npm run prisma:generate --workspace=@asb/backend
RUN npm run build --workspace=@asb/backend

# ── 2) Flutter Web derleme ────────────────────────────────────────────────
# Hazır bir Flutter Docker image'ı (ör. ghcr.io/cirruslabs/flutter) yerine
# SDK'yı resmi depodan doğrudan klonluyoruz. İki gerekçe var: o proje Mayıs
# 2026'dan itibaren tamamen güncellenmeyi bırakıyor, bakımsız kalacak bir
# bağımlılığa kilitlenmek istemedik. Ayrıca en son etiketi (3.44.0) bile
# pubspec.yaml'daki Dart SDK kısıtını (^3.12.2) karşılamıyor, image'ın
# içindeki Dart 3.12.0'da kalmış. Kendi SDK'mızı klonlamak, geliştirme
# makinesiyle (3.44.8) birebir aynı sürümü garanti ediyor.
FROM debian:bookworm-slim AS web-build
RUN apt-get update && apt-get install -y --no-install-recommends \
      git ca-certificates curl xz-utils unzip \
    && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/flutter/flutter.git --depth 1 --branch 3.44.8 /flutter
ENV PATH="/flutter/bin:${PATH}"
RUN git config --global --add safe.directory /flutter && flutter precache --web

WORKDIR /app/packages/app
COPY packages/app/pubspec.yaml packages/app/pubspec.lock ./
RUN flutter pub get
COPY packages/app .
RUN flutter build web --release

# ── 3) Çalışma imajı ───────────────────────────────────────────────────────
FROM node:20-bookworm-slim AS runtime
WORKDIR /app/packages/backend
ENV NODE_ENV=production

# Prisma'nın sorgu motoru (native binary) libssl'e ihtiyaç duyuyor.
# `node:*-slim` imajlarında yok, olmadan "failed to detect libssl" uyarısı
# çıkıyor ve motor yanlış varsayılana düşüp başarısız oluyor.
RUN apt-get update && apt-get install -y --no-install-recommends openssl \
    && rm -rf /var/lib/apt/lists/*

# `prisma` CLI (devDependencies'te) bilinçli olarak budanmadı — container
# ayağa kalkarken `prisma migrate deploy` çalıştırmak için gerekiyor (bkz.
# CMD).
COPY --from=backend-build /app/node_modules /app/node_modules
COPY --from=backend-build /app/packages/shared-types/dist /app/packages/shared-types/dist
COPY --from=backend-build /app/packages/shared-types/package.json /app/packages/shared-types/package.json
# npm workspaces bazı bağımlılıkları (ör. google-auth-library, versiyon
# çakışması yüzünden) kök node_modules'a değil doğrudan
# packages/backend/node_modules'a kuruyor. Sadece kökü kopyalamak
# `Cannot find module 'google-auth-library'` ile çöküyordu. Bu klasör
# package-lock.json değişmediği sürece hep oluşuyor; hoisting davranışı
# değişip klasör hiç oluşmazsa bu COPY build'i kırar, ki bu istediğimiz
# davranış — sessiz eksik bağımlılık yerine build'in patlaması daha iyi.
COPY --from=backend-build /app/packages/backend/node_modules ./node_modules
COPY --from=backend-build /app/packages/backend/dist ./dist
COPY --from=backend-build /app/packages/backend/prisma ./prisma
COPY --from=backend-build /app/packages/backend/package.json ./package.json
# AdminJS dashboard/login bileşenleri (.jsx) bilerek src/ dışında duruyor
# (tsc/eslint JSX'i TypeScript sanıp derleme hatası vermesin diye, bkz.
# admin-panel.module.ts'teki not). Bu yüzden dist/'e hiç girmiyorlar,
# ayrıca kopyalanmaları gerekiyor. Olmadan ComponentLoader dosyayı
# bulamıyor ve uygulama açılışta çöküyor.
COPY --from=backend-build /app/packages/backend/admin-components ./admin-components

# Flutter web build çıktısı `web/` altına — main.ts bunu `process.cwd()`
# (=/app/packages/backend, WORKDIR) + 'web' olarak arıyor.
COPY --from=web-build /app/packages/app/build/web ./web

EXPOSE 3000

# Migration'ı her başlangıçta çalıştırmak tek-replika bu proje için güvenli,
# yarış durumu riski yok. Birden fazla replika olsaydı bu ayrı bir "migrate"
# adımına taşınırdı.
CMD ["sh", "-c", "npx prisma migrate deploy --schema prisma/schema.prisma && node dist/main.js"]
