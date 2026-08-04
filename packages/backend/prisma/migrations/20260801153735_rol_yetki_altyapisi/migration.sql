-- CreateEnum
CREATE TYPE "Yetki" AS ENUM ('duyuru_yonet');

-- CreateTable
CREATE TABLE "rol_yetki" (
    "id" TEXT NOT NULL,
    "rol" "KullaniciRolu" NOT NULL,
    "yetki" "Yetki" NOT NULL,

    CONSTRAINT "rol_yetki_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "rol_yetki_rol_yetki_key" ON "rol_yetki"("rol", "yetki");
