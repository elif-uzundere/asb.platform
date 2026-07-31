-- AlterTable
ALTER TABLE "firma" ADD COLUMN     "guncelleme_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "kurulus_tarihi" TIMESTAMP(3),
ADD COLUMN     "personel_sayisi" INTEGER,
ADD COLUMN     "web_adres" VARCHAR(255);
