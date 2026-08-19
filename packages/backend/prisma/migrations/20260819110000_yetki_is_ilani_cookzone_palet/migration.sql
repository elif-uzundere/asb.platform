-- İş İlanları/Cookzone/Palet Tesisi için de RolYetki tabanlı izin (18.08.2026,
-- Berzan'ın isteği — ikinci_el_yonet ile aynı desen, admin-only modüllere
-- (Firma, Banner) BİLİNÇLİ olarak eklenmedi).

ALTER TYPE "Yetki" ADD VALUE 'is_ilani_yonet';
ALTER TYPE "Yetki" ADD VALUE 'cookzone_yonet';
ALTER TYPE "Yetki" ADD VALUE 'palet_tesisi_yonet';
