-- CreateTable
CREATE TABLE "acil_durum_birimi" (
    "id" TEXT NOT NULL,
    "ad" VARCHAR(120) NOT NULL,
    "tur" VARCHAR(50) NOT NULL,
    "telefon" VARCHAR(30),
    "eposta" VARCHAR(150),
    "aciklama" TEXT,
    "calisma_saatleri" TEXT,
    "aktif" BOOLEAN NOT NULL DEFAULT true,
    "sira" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "acil_durum_birimi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "toplanma_alani" (
    "id" TEXT NOT NULL,
    "ad" VARCHAR(120) NOT NULL,
    "aciklama" TEXT,
    "enlem" DECIMAL(10,7) NOT NULL,
    "boylam" DECIMAL(10,7) NOT NULL,
    "aktif" BOOLEAN NOT NULL DEFAULT true,
    "sira" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "toplanma_alani_pkey" PRIMARY KEY ("id")
);
