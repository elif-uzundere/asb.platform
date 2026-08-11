/*
  Warnings:

  - You are about to drop the `acil_durum_birimi` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropTable
DROP TABLE "acil_durum_birimi";

-- CreateTable
CREATE TABLE "acil_durum_bilgisi" (
    "id" TEXT NOT NULL,
    "tur" VARCHAR(50) NOT NULL,
    "telefon" VARCHAR(30),
    "eposta" VARCHAR(150),
    "aciklama" TEXT,
    "calisma_saatleri" TEXT,

    CONSTRAINT "acil_durum_bilgisi_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "acil_durum_bilgisi_tur_key" ON "acil_durum_bilgisi"("tur");
