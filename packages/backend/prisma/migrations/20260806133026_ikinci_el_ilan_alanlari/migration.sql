/*
  Warnings:

  - Added the required column `sehir` to the `ikinci_el_ilani` table without a default value. This is not possible if the table is not empty.
  - Added the required column `urun_durumu` to the `ikinci_el_ilani` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "ikinci_el_ilani" ADD COLUMN     "sehir" VARCHAR(80) NOT NULL,
ADD COLUMN     "urun_durumu" VARCHAR(50) NOT NULL;
