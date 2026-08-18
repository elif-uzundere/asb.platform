-- Acil Durum bildirimlerinin türe göre ilgili ekibe yönlendirilebilmesi için
-- 6 yeni rol + AcilDurumTuru'na kantar/gumruk eklendi.
ALTER TYPE "KullaniciRolu" ADD VALUE 'itfaiye_ekibi';
ALTER TYPE "KullaniciRolu" ADD VALUE 'guvenlik_ekibi';
ALTER TYPE "KullaniciRolu" ADD VALUE 'tekin_isg_ekibi';
ALTER TYPE "KullaniciRolu" ADD VALUE 'kantar_ekibi';
ALTER TYPE "KullaniciRolu" ADD VALUE 'gumruk_ekibi';
ALTER TYPE "KullaniciRolu" ADD VALUE 'sirket_isg_ekibi';

ALTER TYPE "AcilDurumTuru" ADD VALUE 'kantar';
ALTER TYPE "AcilDurumTuru" ADD VALUE 'gumruk';
