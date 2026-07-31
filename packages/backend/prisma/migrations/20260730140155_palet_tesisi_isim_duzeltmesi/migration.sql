/*
  Warnings:

  - You are about to drop the `paket_teslimi` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "PaletTesisiDurumu" AS ENUM ('beklemede', 'bolgede', 'teslim_edildi');

-- DropForeignKey
ALTER TABLE "paket_teslimi" DROP CONSTRAINT "paket_teslimi_kullanici_id_fkey";

-- DropForeignKey
ALTER TABLE "paket_teslimi" DROP CONSTRAINT "paket_teslimi_teslim_noktasi_id_fkey";

-- DropTable
DROP TABLE "paket_teslimi";

-- DropEnum
DROP TYPE "PaketTeslimiDurumu";

-- CreateTable
CREATE TABLE "palet_tesisi" (
    "id" TEXT NOT NULL,
    "kullanici_id" TEXT NOT NULL,
    "kargo_firmasi" VARCHAR(100),
    "takip_no" VARCHAR(100),
    "durum" "PaletTesisiDurumu" NOT NULL DEFAULT 'beklemede',
    "teslim_noktasi_id" TEXT,
    "olusturma_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "palet_tesisi_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "palet_tesisi" ADD CONSTRAINT "palet_tesisi_kullanici_id_fkey" FOREIGN KEY ("kullanici_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "palet_tesisi" ADD CONSTRAINT "palet_tesisi_teslim_noktasi_id_fkey" FOREIGN KEY ("teslim_noktasi_id") REFERENCES "bolge_noktasi"("id") ON DELETE SET NULL ON UPDATE CASCADE;
