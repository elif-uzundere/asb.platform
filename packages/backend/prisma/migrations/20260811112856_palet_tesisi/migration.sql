-- CreateTable
CREATE TABLE "palet_tesisi_bilgisi" (
    "id" TEXT NOT NULL,
    "telefon" VARCHAR(30),
    "eposta" VARCHAR(150),
    "adres" TEXT,
    "aciklama" TEXT,
    "calisma_saatleri" TEXT,

    CONSTRAINT "palet_tesisi_bilgisi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "palet" (
    "id" TEXT NOT NULL,
    "ad" VARCHAR(120) NOT NULL,
    "aciklama" TEXT,
    "olcu" VARCHAR(80),
    "gorsel_url" TEXT,
    "aktif" BOOLEAN NOT NULL DEFAULT true,
    "sira" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "palet_pkey" PRIMARY KEY ("id")
);
