-- AlterTable
ALTER TABLE "cookzone_siparis" ADD COLUMN     "alinma_saati" TIMESTAMP(3) NOT NULL,
ALTER COLUMN "durum" SET DEFAULT 'beklemede';

-- AlterTable
ALTER TABLE "kullanici" ADD COLUMN     "cookzone_isletme_id" TEXT;

-- CreateTable
CREATE TABLE "cihaz_tokeni" (
    "id" TEXT NOT NULL,
    "kullanici_id" TEXT NOT NULL,
    "token" VARCHAR(255) NOT NULL,
    "platform" "CihazPlatformu" NOT NULL,
    "olusturma_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cihaz_tokeni_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "cihaz_tokeni_token_key" ON "cihaz_tokeni"("token");

-- AddForeignKey
ALTER TABLE "kullanici" ADD CONSTRAINT "kullanici_cookzone_isletme_id_fkey" FOREIGN KEY ("cookzone_isletme_id") REFERENCES "cookzone_isletme"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cihaz_tokeni" ADD CONSTRAINT "cihaz_tokeni_kullanici_id_fkey" FOREIGN KEY ("kullanici_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
