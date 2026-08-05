-- CreateEnum
CREATE TYPE "DestekTalebiDurumu" AS ENUM ('beklemede', 'yanitlandi', 'kapali');

-- CreateTable
CREATE TABLE "destek_talebi" (
    "id" TEXT NOT NULL,
    "baslik" VARCHAR(150) NOT NULL,
    "aciklama" TEXT NOT NULL,
    "durum" "DestekTalebiDurumu" NOT NULL DEFAULT 'beklemede',
    "olusturma_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "kullanici_id" TEXT NOT NULL,

    CONSTRAINT "destek_talebi_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "destek_talebi" ADD CONSTRAINT "destek_talebi_kullanici_id_fkey" FOREIGN KEY ("kullanici_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
