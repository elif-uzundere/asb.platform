-- CreateEnum
CREATE TYPE "KullaniciRolu" AS ENUM ('ziyaretci', 'firma_calisani', 'firma_yetkilisi', 'admin');

-- CreateEnum
CREATE TYPE "FirmaOnayDurumu" AS ENUM ('beklemede', 'onaylandi', 'reddedildi');

-- CreateEnum
CREATE TYPE "IsIlaniDurumu" AS ENUM ('aktif', 'kapali');

-- CreateEnum
CREATE TYPE "IsBasvurusuDurumu" AS ENUM ('beklemede', 'incelendi', 'reddedildi', 'kabul');

-- CreateEnum
CREATE TYPE "IkinciElIlaniDurumu" AS ENUM ('aktif', 'satildi', 'pasif');

-- CreateEnum
CREATE TYPE "BolgeNoktasiTuru" AS ENUM ('firma', 'giris_cikis', 'ortak_alan', 'acil_nokta');

-- CreateEnum
CREATE TYPE "CookzoneSiparisDurumu" AS ENUM ('alindi', 'hazirlaniyor', 'hazir', 'teslim_edildi');

-- CreateEnum
CREATE TYPE "AcilDurumTuru" AS ENUM ('yangin', 'kaza', 'saglik', 'diger');

-- CreateEnum
CREATE TYPE "AcilDurumBildirimDurumu" AS ENUM ('yeni', 'inceleniyor', 'kapatildi');

-- CreateEnum
CREATE TYPE "PaketTeslimiDurumu" AS ENUM ('beklemede', 'bolgede', 'teslim_edildi');

-- CreateTable
CREATE TABLE "kullanici" (
    "id" TEXT NOT NULL,
    "email" VARCHAR(150) NOT NULL,
    "telefon" VARCHAR(20),
    "sifre_hash" VARCHAR(255),
    "ad" VARCHAR(60) NOT NULL,
    "soyad" VARCHAR(60) NOT NULL,
    "firma_id" TEXT,
    "rol" "KullaniciRolu" NOT NULL,
    "eposta_dogrulandi" BOOLEAN NOT NULL DEFAULT false,
    "olusturma_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "guncelleme_tarihi" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "kullanici_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "firma" (
    "id" TEXT NOT NULL,
    "ad" VARCHAR(150) NOT NULL,
    "logo_url" VARCHAR(255),
    "sektor" VARCHAR(80) NOT NULL,
    "adres" VARCHAR(255) NOT NULL,
    "telefon" VARCHAR(20),
    "eposta" VARCHAR(150),
    "onay_durumu" "FirmaOnayDurumu" NOT NULL DEFAULT 'beklemede',
    "aktif" BOOLEAN NOT NULL DEFAULT true,
    "olusturma_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "firma_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "banner" (
    "id" TEXT NOT NULL,
    "gorsel_url" VARCHAR(255) NOT NULL,
    "link_url" VARCHAR(255),
    "sira" INTEGER NOT NULL,
    "aktif" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "banner_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "duyuru" (
    "id" TEXT NOT NULL,
    "baslik" VARCHAR(200) NOT NULL,
    "icerik" TEXT NOT NULL,
    "kategori" VARCHAR(60),
    "yayin_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "olusturan_admin_id" TEXT NOT NULL,

    CONSTRAINT "duyuru_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "is_ortagi" (
    "id" TEXT NOT NULL,
    "ad" VARCHAR(150) NOT NULL,
    "logo_url" VARCHAR(255) NOT NULL,
    "kategori" VARCHAR(80),

    CONSTRAINT "is_ortagi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "is_ilani" (
    "id" TEXT NOT NULL,
    "firma_id" TEXT NOT NULL,
    "baslik" VARCHAR(150) NOT NULL,
    "aciklama" TEXT NOT NULL,
    "konum" VARCHAR(150),
    "yayin_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "durum" "IsIlaniDurumu" NOT NULL DEFAULT 'aktif',
    "olusturan_kullanici_id" TEXT NOT NULL,

    CONSTRAINT "is_ilani_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "is_basvurusu" (
    "id" TEXT NOT NULL,
    "is_ilani_id" TEXT NOT NULL,
    "kullanici_id" TEXT NOT NULL,
    "basvuru_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "durum" "IsBasvurusuDurumu" NOT NULL DEFAULT 'beklemede',

    CONSTRAINT "is_basvurusu_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ikinci_el_ilani" (
    "id" TEXT NOT NULL,
    "kullanici_id" TEXT NOT NULL,
    "baslik" VARCHAR(150) NOT NULL,
    "aciklama" TEXT NOT NULL,
    "fiyat" DECIMAL(10,2) NOT NULL,
    "kategori" VARCHAR(80) NOT NULL,
    "fotograf_urls" TEXT[],
    "durum" "IkinciElIlaniDurumu" NOT NULL DEFAULT 'aktif',
    "olusturma_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ikinci_el_ilani_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bolge_noktasi" (
    "id" TEXT NOT NULL,
    "ad" VARCHAR(150) NOT NULL,
    "tur" "BolgeNoktasiTuru" NOT NULL,
    "firma_id" TEXT,
    "enlem" DECIMAL(9,6) NOT NULL,
    "boylam" DECIMAL(9,6) NOT NULL,

    CONSTRAINT "bolge_noktasi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cookzone_isletme" (
    "id" TEXT NOT NULL,
    "ad" VARCHAR(150) NOT NULL,
    "bolge_noktasi_id" TEXT NOT NULL,

    CONSTRAINT "cookzone_isletme_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cookzone_menu_ogesi" (
    "id" TEXT NOT NULL,
    "isletme_id" TEXT NOT NULL,
    "ad" VARCHAR(150) NOT NULL,
    "aciklama" TEXT,
    "fiyat" DECIMAL(8,2) NOT NULL,
    "kategori" VARCHAR(60) NOT NULL,
    "aktif" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "cookzone_menu_ogesi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cookzone_siparis" (
    "id" TEXT NOT NULL,
    "kullanici_id" TEXT NOT NULL,
    "isletme_id" TEXT NOT NULL,
    "durum" "CookzoneSiparisDurumu" NOT NULL DEFAULT 'alindi',
    "toplam_tutar" DECIMAL(10,2) NOT NULL,
    "olusturma_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "cookzone_siparis_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "cookzone_siparis_kalemi" (
    "id" TEXT NOT NULL,
    "siparis_id" TEXT NOT NULL,
    "menu_ogesi_id" TEXT NOT NULL,
    "adet" INTEGER NOT NULL,

    CONSTRAINT "cookzone_siparis_kalemi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "acil_durum_bildirimi" (
    "id" TEXT NOT NULL,
    "kullanici_id" TEXT NOT NULL,
    "tur" "AcilDurumTuru" NOT NULL,
    "enlem" DECIMAL(9,6),
    "boylam" DECIMAL(9,6),
    "bolge_noktasi_id" TEXT,
    "aciklama" TEXT,
    "durum" "AcilDurumBildirimDurumu" NOT NULL DEFAULT 'yeni',
    "olusturma_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "acil_durum_bildirimi_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "paket_teslimi" (
    "id" TEXT NOT NULL,
    "kullanici_id" TEXT NOT NULL,
    "kargo_firmasi" VARCHAR(100),
    "takip_no" VARCHAR(100),
    "durum" "PaketTeslimiDurumu" NOT NULL DEFAULT 'beklemede',
    "teslim_noktasi_id" TEXT,
    "olusturma_tarihi" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "paket_teslimi_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "kullanici_email_key" ON "kullanici"("email");

-- CreateIndex
CREATE UNIQUE INDEX "kullanici_telefon_key" ON "kullanici"("telefon");

-- AddForeignKey
ALTER TABLE "kullanici" ADD CONSTRAINT "kullanici_firma_id_fkey" FOREIGN KEY ("firma_id") REFERENCES "firma"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "duyuru" ADD CONSTRAINT "duyuru_olusturan_admin_id_fkey" FOREIGN KEY ("olusturan_admin_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "is_ilani" ADD CONSTRAINT "is_ilani_firma_id_fkey" FOREIGN KEY ("firma_id") REFERENCES "firma"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "is_ilani" ADD CONSTRAINT "is_ilani_olusturan_kullanici_id_fkey" FOREIGN KEY ("olusturan_kullanici_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "is_basvurusu" ADD CONSTRAINT "is_basvurusu_is_ilani_id_fkey" FOREIGN KEY ("is_ilani_id") REFERENCES "is_ilani"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "is_basvurusu" ADD CONSTRAINT "is_basvurusu_kullanici_id_fkey" FOREIGN KEY ("kullanici_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ikinci_el_ilani" ADD CONSTRAINT "ikinci_el_ilani_kullanici_id_fkey" FOREIGN KEY ("kullanici_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bolge_noktasi" ADD CONSTRAINT "bolge_noktasi_firma_id_fkey" FOREIGN KEY ("firma_id") REFERENCES "firma"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cookzone_isletme" ADD CONSTRAINT "cookzone_isletme_bolge_noktasi_id_fkey" FOREIGN KEY ("bolge_noktasi_id") REFERENCES "bolge_noktasi"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cookzone_menu_ogesi" ADD CONSTRAINT "cookzone_menu_ogesi_isletme_id_fkey" FOREIGN KEY ("isletme_id") REFERENCES "cookzone_isletme"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cookzone_siparis" ADD CONSTRAINT "cookzone_siparis_kullanici_id_fkey" FOREIGN KEY ("kullanici_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cookzone_siparis" ADD CONSTRAINT "cookzone_siparis_isletme_id_fkey" FOREIGN KEY ("isletme_id") REFERENCES "cookzone_isletme"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cookzone_siparis_kalemi" ADD CONSTRAINT "cookzone_siparis_kalemi_siparis_id_fkey" FOREIGN KEY ("siparis_id") REFERENCES "cookzone_siparis"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "cookzone_siparis_kalemi" ADD CONSTRAINT "cookzone_siparis_kalemi_menu_ogesi_id_fkey" FOREIGN KEY ("menu_ogesi_id") REFERENCES "cookzone_menu_ogesi"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "acil_durum_bildirimi" ADD CONSTRAINT "acil_durum_bildirimi_kullanici_id_fkey" FOREIGN KEY ("kullanici_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "acil_durum_bildirimi" ADD CONSTRAINT "acil_durum_bildirimi_bolge_noktasi_id_fkey" FOREIGN KEY ("bolge_noktasi_id") REFERENCES "bolge_noktasi"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "paket_teslimi" ADD CONSTRAINT "paket_teslimi_kullanici_id_fkey" FOREIGN KEY ("kullanici_id") REFERENCES "kullanici"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "paket_teslimi" ADD CONSTRAINT "paket_teslimi_teslim_noktasi_id_fkey" FOREIGN KEY ("teslim_noktasi_id") REFERENCES "bolge_noktasi"("id") ON DELETE SET NULL ON UPDATE CASCADE;
