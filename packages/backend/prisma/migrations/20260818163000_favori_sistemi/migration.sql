-- Favoriler: İkinci El ilanı / Firma / İş İlanı için TEK ortak tablo
-- (18.08.2026, Berzan'ın isteği).

CREATE TYPE "FavoriHedefTuru" AS ENUM ('ikinci_el', 'firma', 'is_ilani');

CREATE TABLE "favori" (
    "id" TEXT NOT NULL,
    "kullanici_id" TEXT NOT NULL,
    "hedef_turu" "FavoriHedefTuru" NOT NULL,
    "hedef_id" TEXT NOT NULL,
    "olusturma_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "favori_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "favori_kullanici_id_hedef_turu_hedef_id_key" ON "favori"("kullanici_id", "hedef_turu", "hedef_id");

ALTER TABLE "favori" ADD CONSTRAINT "favori_kullanici_id_fkey" FOREIGN KEY ("kullanici_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
