-- İkinci El Pazar: şirket-içi yeniden yapılanma (18.08.2026, Berzan'ın isteği)
-- - ilan girme izni artık RolYetki üzerinden (yeni "departman" rolü YOK)
-- - iletişim telefonu zorunlu
-- - "öne çıkan" bayrağı (Ana Sayfa entegrasyonu için)
-- Cookzone menü öğesine görsel alanı eklendi (menü CRUD ile birlikte).

ALTER TYPE "Yetki" ADD VALUE 'ikinci_el_yonet';

ALTER TABLE "ikinci_el_ilani" ADD COLUMN "iletisim_telefonu" VARCHAR(20) NOT NULL DEFAULT '';
ALTER TABLE "ikinci_el_ilani" ALTER COLUMN "iletisim_telefonu" DROP DEFAULT;

ALTER TABLE "ikinci_el_ilani" ADD COLUMN "one_cikan" BOOLEAN NOT NULL DEFAULT false;

ALTER TABLE "cookzone_menu_ogesi" ADD COLUMN "gorsel_url" VARCHAR(255);
