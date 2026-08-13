-- Postgres yeni bir enum değerini AYNI transaction içinde (örn. bir kolonun
-- DEFAULT'u olarak) kullanmaya izin vermiyor — önce commit edilmesi gerekiyor.
-- Bu yüzden enum eklemeleri, onları kullanan diğer değişikliklerden
-- (bir sonraki migration) ayrı bir migration'da.

-- CreateEnum
CREATE TYPE "CihazPlatformu" AS ENUM ('android', 'ios', 'web');

-- AlterEnum
ALTER TYPE "CookzoneSiparisDurumu" ADD VALUE 'beklemede';

-- AlterEnum
ALTER TYPE "KullaniciRolu" ADD VALUE 'cookzone_yetkilisi';
