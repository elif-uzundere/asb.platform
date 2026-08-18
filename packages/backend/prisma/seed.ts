// Geliştirme/test verisi. `npx prisma db seed` ile çalışır (ts-node üzerinden;
// bkz. package.json → prisma.seed). Tip denetimi prisma/tsconfig.json ile.
//
// TEKRAR ÇALIŞTIRILABİLİR (idempotent): her çalıştırmada kendi eklediği
// kayıtları önce adlarına göre siler, sonra yeniden yazar. Böylece 3 kez
// çalıştırınca 24 satır oluşmaz. Seed dışındaki firmalara DOKUNMAZ.

// `main.ts`'teki gibi açıkça yükleniyor — `prisma/tsconfig.json` üzerinden
// çalıştırılan `ts-node` çağrısı, Prisma CLI wrapper'ının (`npx prisma db
// seed`) örtük .env yüklemesinden farklı olarak bunu otomatik yapmıyor.
import 'dotenv/config';
import { copyFileSync, mkdirSync } from 'fs';
import { join } from 'path';
import { KullaniciRolu, PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

// `uploads/` .gitignore'da (runtime'da FileStoragePort ile üretilen, takip
// edilmeyen dosyalar için) — ama İş Ortakları logoları GERÇEK/kalıcı proje
// varlığı, kayıp olmaması için git'e giren `prisma/seed-assets/` altında
// tutuluyor, seed her çalıştığında oradan `uploads/`'a kopyalanıyor.
const UPLOADS_DIR = join(process.cwd(), 'uploads');
const SEED_ASSETS_DIR = join(process.cwd(), 'prisma', 'seed-assets');

/** Tüm seed hesaplarının ortak test şifresi — US-001'in min-8-karakter +
 * 1-rakam kuralına uyar, gerçek login akışıyla test edilebilsin diye. */
const SEED_SIFRE = 'Test1234';

async function main() {
  await rolYetkileriniYaz();
  await firmalariYaz();
  await duyurulariYaz();
  await isIlanlariYaz();
  await cookzoneYaz();
  await paletTesisiYetkilisiYaz();
  await isOrtaklariniYaz();
  await acilDurumBilgileriniYaz();
  await toplanmaAlanlariniYaz();
  await acilDurumEkipleriniYaz();
}

/** admin rolüne duyuru_yonet yetkisini tanımlar — `upsert` olduğu için
 * tekrar çalıştırmak yinelenen satır oluşturmaz. */
async function rolYetkileriniYaz() {
  await prisma.rolYetki.upsert({
    where: { rol_yetki: { rol: 'admin', yetki: 'duyuru_yonet' } },
    update: {},
    create: { rol: 'admin', yetki: 'duyuru_yonet' },
  });
  // İkinci El Pazar ilan girme izni — eskiden @Roller('admin','firma_yetkilisi')
  // ile sabitti, artık RolYetki üzerinden (admin panelinden değiştirilebilir).
  // Davranış aynı kalsın diye aynı iki rolle başlatılıyor.
  for (const rol of ['admin', 'firma_yetkilisi'] as const) {
    await prisma.rolYetki.upsert({
      where: { rol_yetki: { rol, yetki: 'ikinci_el_yonet' } },
      update: {},
      create: { rol, yetki: 'ikinci_el_yonet' },
    });
  }
  console.log('Rol-yetki eşleşmesi yazıldı: admin → duyuru_yonet, admin/firma_yetkilisi → ikinci_el_yonet.');
}

async function firmalariYaz() {
  console.log('Firma seed verisi yazılıyor...');

  const firmalar = [
    {
      ad: 'Ege Lojistik A.Ş.',
      sektor: 'Lojistik',
      adres: 'Serbest Bölge, 3. Cadde No:12',
      telefon: '02321234567',
      eposta: 'info@egelojistik.com',
      onayDurumu: 'onaylandi' as const,
      webAdres: 'https://www.egelojistik.com',
      kurulusTarihi: new Date('2005-03-15'),
      personelSayisi: 85,
    },
    {
      ad: 'Anadolu Tekstil San. ve Tic. Ltd. Şti.',
      sektor: 'Tekstil',
      adres: 'Serbest Bölge, 5. Cadde No:8',
      telefon: '02327654321',
      eposta: 'iletisim@anadolutekstil.com',
      onayDurumu: 'onaylandi' as const,
      webAdres: 'https://www.anadolutekstil.com',
      kurulusTarihi: new Date('1998-06-01'),
      personelSayisi: 210,
    },
    {
      ad: 'Marmara Elektronik Yazılım A.Ş.',
      sektor: 'Elektronik',
      adres: 'Serbest Bölge, 2. Cadde No:21',
      telefon: '02329876543',
      eposta: 'info@marmaraelektronik.com',
      onayDurumu: 'onaylandi' as const,
      webAdres: 'https://www.marmaraelektronik.com',
      kurulusTarihi: new Date('2015-09-10'),
      personelSayisi: 42,
    },
    {
      ad: 'Karadeniz Gıda İhracat Ltd. Şti.',
      sektor: 'Gıda',
      adres: 'Serbest Bölge, 7. Cadde No:15',
      telefon: '02321122334',
      eposta: 'ihracat@karadenizgida.com',
      onayDurumu: 'onaylandi' as const,
      webAdres: 'https://www.karadenizgida.com',
      kurulusTarihi: new Date('2001-11-20'),
      personelSayisi: 130,
    },
    {
      ad: 'Toros İnşaat Malzemeleri A.Ş.',
      sektor: 'İnşaat',
      adres: 'Serbest Bölge, 1. Cadde No:4',
      telefon: '02325566778',
      eposta: 'info@torosinsaat.com',
      onayDurumu: 'onaylandi' as const,
      webAdres: 'https://www.torosinsaat.com',
      kurulusTarihi: new Date('1992-04-05'),
      personelSayisi: 175,
    },
    {
      ad: 'Akdeniz Kimya Sanayi Ltd. Şti.',
      sektor: 'Kimya',
      adres: 'Serbest Bölge, 6. Cadde No:19',
      telefon: '02323344556',
      eposta: 'info@akdenizkimya.com',
      onayDurumu: 'onaylandi' as const,
      webAdres: 'https://www.akdenizkimya.com',
      kurulusTarihi: new Date('2008-02-28'),
      personelSayisi: 60,
    },
    {
      // Onay bekleyen — listede GÖRÜNMEMELİ, filtre testi için
      ad: 'Yeni Nesil Teknoloji A.Ş.',
      sektor: 'Teknoloji',
      adres: 'Serbest Bölge, 4. Cadde No:9',
      telefon: '02327788990',
      eposta: 'info@yenineslteknoloji.com',
      onayDurumu: 'beklemede' as const,
      webAdres: 'https://www.yenineslteknoloji.com',
      kurulusTarihi: new Date('2022-01-10'),
      personelSayisi: 15,
    },
    {
      // Reddedilmiş — listede GÖRÜNMEMELİ, filtre testi için. Yeni alanlar
      // BİLEREK boş bırakıldı — UI'ın eksik veriyle de doğru çalıştığını
      // (bkz. firma_detay_ekrani.dart'taki `if (firma.webAdres != null)` gibi
      // koşullu bloklar) test edebilecek tek kayıt bu.
      ad: 'Test Reddedilen Firma Ltd. Şti.',
      sektor: 'Diğer',
      adres: 'Serbest Bölge, 9. Cadde No:1',
      telefon: '02320000000',
      eposta: 'test@reddedilen.com',
      onayDurumu: 'reddedildi' as const,
    },
  ];

  // Önce bu seed'in daha önce eklediği kayıtları temizle (ada göre eşleştirip).
  // Elle eklenmiş başka firmalar etkilenmez.
  //
  // `isIlanlariYaz()` bu firmalara iş ilanı + firma_yetkilisi hesabı bağladığı
  // için (FK: is_ilani.firma_id NOT NULL, kullanici.firma_id nullable) düz
  // bir `firma.deleteMany` artık P2003 (foreign key constraint) ile patlıyor.
  // Silmeden önce bağımlıları temizlemek zorundayız: önce başvurular (ilana
  // bağlı), sonra ilanlar, sonra kullanıcıların firma bağlantısı (hesabı
  // SİLMİYORUZ, sadece firmaId'sini null'a çekiyoruz — `isIlanlariYaz()` aynı
  // çalıştırmada onu zaten doğru firmaId ile yeniden upsert edecek).
  const adlar = firmalar.map((f) => f.ad);
  const eskiFirmalar = await prisma.firma.findMany({ where: { ad: { in: adlar } }, select: { id: true } });
  if (eskiFirmalar.length > 0) {
    const eskiFirmaIdler = eskiFirmalar.map((f) => f.id);
    await prisma.isBasvurusu.deleteMany({ where: { isIlani: { firmaId: { in: eskiFirmaIdler } } } });
    await prisma.isIlani.deleteMany({ where: { firmaId: { in: eskiFirmaIdler } } });
    await prisma.kullanici.updateMany({ where: { firmaId: { in: eskiFirmaIdler } }, data: { firmaId: null } });
  }

  const { count: silinen } = await prisma.firma.deleteMany({
    where: { ad: { in: adlar } },
  });
  if (silinen > 0) {
    console.log(`Önceki seed kaydı temizlendi: ${silinen} satır.`);
  }

  await prisma.firma.createMany({ data: firmalar });

  console.log(`${firmalar.length} firma oluşturuldu.`);
}

/**
 * `olusturanKullaniciId` zorunlu (NOT NULL) — bir admin kaydı bulunamazsa
 * (tertemiz bir veritabanında henüz kimse kayıt olup admin yapılmadıysa)
 * seed'i çökertmek yerine sessizce atlıyoruz. Firma/rol-yetki seed'i
 * kullanıcıdan bağımsız olduğu için onlar yine de yazılır.
 */
async function duyurulariYaz() {
  const admin = await prisma.kullanici.findFirst({ where: { rol: 'admin' } });
  if (!admin) {
    console.log(
      'Duyuru seed verisi atlandı: henüz admin rolünde bir kullanıcı yok (önce kayıt olup admin yapılması gerekiyor).',
    );
    return;
  }

  console.log('Duyuru seed verisi yazılıyor...');

  const duyurular = [
    {
      baslik: 'Bölge İçi Elektrik Kesintisi Bilgilendirmesi',
      icerik:
        'Değerli firma yetkilileri ve çalışanları,\n\n15 Ağustos 2026 Cuma günü saat 09:00 - 13:00 arasında, bölge içi trafo bakım çalışması nedeniyle 3. ve 5. Cadde hattında planlı elektrik kesintisi yaşanacaktır.\n\nKesinti süresince jeneratör destekli alanlar (Bölge Yönetim Binası, Acil Durum Merkezi) etkilenmeyecektir.\n\nAnlayışınız için teşekkür ederiz.\n\nAvrupa Serbest Bölgesi Yönetimi',
      kategori: 'Bakım',
    },
    {
      baslik: 'Yeni Firma Kayıt Süreci Hakkında',
      icerik:
        'Bölgemize yeni katılan firmaların kayıt başvuruları artık mobil uygulama üzerinden de takip edilebilmektedir. Başvurunuzun onay durumunu Profil ekranınızdan görüntüleyebilirsiniz.',
      kategori: 'Duyuru',
    },
    {
      baslik: 'Bölge İçi Ulaşım Güzergahı Değişikliği',
      icerik:
        'Yol yenileme çalışmaları nedeniyle 2. Cadde üzerindeki servis güzergahı geçici olarak 4. Cadde üzerinden yönlendirilmiştir. Değişiklik bir sonraki duyuruya kadar geçerlidir.',
      kategori: 'Genel',
    },
  ];

  const basliklar = duyurular.map((d) => d.baslik);
  const { count: silinen } = await prisma.duyuru.deleteMany({
    where: { baslik: { in: basliklar } },
  });
  if (silinen > 0) {
    console.log(`Önceki seed kaydı temizlendi: ${silinen} satır.`);
  }

  await prisma.duyuru.createMany({
    data: duyurular.map((d) => ({ ...d, olusturanKullaniciId: admin.id })),
  });

  console.log(`${duyurular.length} duyuru oluşturuldu.`);
}

/**
 * İş ilanları + başvurular. Onaylı 3 firmaya birer `firma_yetkilisi` hesabı
 * (BR-2 gereği ilan açabilmek için firma onaylı OLMALI, bu yüzden onaylı
 * olmayanlara değil bu üçüne bağlanıyor), her firmaya 2 ilan, 2 aday hesabı
 * ve ilk ilana 2 örnek başvuru.
 *
 * `firmalariYaz()`'dan SONRA çalışmak zorunda (firma id'lerine ihtiyaç var).
 * Firma seed verisi yoksa (biri o fonksiyonu değiştirip adları kırdıysa)
 * sessizce atlanıyor — `duyurulariYaz()`'daki "admin yoksa atla" deseninin
 * aynısı.
 */
async function isIlanlariYaz() {
  const firmaYetkilileri = [
    { firmaAdi: 'Ege Lojistik A.Ş.', email: 'yetkili.egelojistik@example.com' },
    { firmaAdi: 'Anadolu Tekstil San. ve Tic. Ltd. Şti.', email: 'yetkili.anadolutekstil@example.com' },
    { firmaAdi: 'Marmara Elektronik Yazılım A.Ş.', email: 'yetkili.marmaraelektronik@example.com' },
  ];

  const firmalar = await prisma.firma.findMany({
    where: { ad: { in: firmaYetkilileri.map((f) => f.firmaAdi) } },
  });
  if (firmalar.length === 0) {
    console.log('İş ilanı seed verisi atlandı: firma seed verisi bulunamadı (önce firmalariYaz() çalışmalı).');
    return;
  }
  const firmaIdAdaGore = new Map(firmalar.map((f) => [f.ad, f.id]));

  console.log('İş ilanı seed verisi yazılıyor...');

  const sifreHash = await bcrypt.hash(SEED_SIFRE, 10);

  // Her firmaya bağlı bir firma_yetkilisi hesabı — upsert, çünkü email
  // unique ve bu hesaplar başka seed çalıştırmalarında da aynı kalmalı
  // (id'leri değişirse o hesapla giriş yapan kişi şaşırırdı).
  const yetkiliIdFirmaIdGore = new Map<string, string>();
  for (const { firmaAdi, email } of firmaYetkilileri) {
    const firmaId = firmaIdAdaGore.get(firmaAdi);
    if (!firmaId) continue;
    const kullanici = await prisma.kullanici.upsert({
      where: { email },
      update: { firmaId, rol: 'firma_yetkilisi' },
      create: {
        email,
        sifreHash,
        ad: 'Firma',
        soyad: 'Yetkilisi',
        rol: 'firma_yetkilisi',
        firmaId,
        epostaDogrulandi: true,
      },
    });
    yetkiliIdFirmaIdGore.set(firmaId, kullanici.id);
  }

  const ilanlar = [
    {
      firmaAdi: 'Ege Lojistik A.Ş.',
      baslik: 'Depo Sorumlusu',
      aciklama: 'Bölge içi lojistik depomuzda tam zamanlı çalışacak, forklift kullanabilen depo sorumlusu arıyoruz.',
      konum: '3. Cadde',
      durum: 'aktif' as const,
    },
    {
      firmaAdi: 'Ege Lojistik A.Ş.',
      baslik: 'Lojistik Uzmanı',
      aciklama: 'Nakliye planlaması ve sevkiyat takibinden sorumlu, en az 2 yıl deneyimli lojistik uzmanı arıyoruz.',
      konum: '3. Cadde',
      durum: 'aktif' as const,
    },
    {
      firmaAdi: 'Anadolu Tekstil San. ve Tic. Ltd. Şti.',
      baslik: 'Üretim Sorumlusu',
      aciklama: 'Üretim hattının günlük planlamasını ve vardiya koordinasyonunu yürütecek üretim sorumlusu arıyoruz.',
      konum: '5. Cadde',
      durum: 'aktif' as const,
    },
    {
      firmaAdi: 'Anadolu Tekstil San. ve Tic. Ltd. Şti.',
      baslik: 'Kalite Kontrol Uzmanı',
      aciklama: 'Kontenjan doldu — kapalı ilan örneği (UI\'ın kapalı durumu doğru göstermesini test etmek için).',
      konum: '5. Cadde',
      durum: 'kapali' as const,
    },
    {
      firmaAdi: 'Marmara Elektronik Yazılım A.Ş.',
      baslik: 'Yazılım Geliştirici',
      aciklama: 'TypeScript/Flutter tecrübesi olan, ekibimize katılacak yazılım geliştirici arıyoruz.',
      konum: '2. Cadde',
      durum: 'aktif' as const,
    },
    {
      firmaAdi: 'Marmara Elektronik Yazılım A.Ş.',
      baslik: 'Sistem Yöneticisi',
      aciklama: 'Sunucu ve ağ altyapısından sorumlu, 7/24 nöbet sistemine uyumlu sistem yöneticisi arıyoruz.',
      konum: '2. Cadde',
      durum: 'aktif' as const,
    },
  ];

  // Önceki seed çalıştırmasından kalan ilanları (ve onlara bağlı
  // başvuruları — FK kısıtı yüzünden ÖNCE başvuru silinmeli) temizle.
  const basliklar = ilanlar.map((i) => i.baslik);
  const eskiIlanlar = await prisma.isIlani.findMany({
    where: { baslik: { in: basliklar } },
    select: { id: true },
  });
  if (eskiIlanlar.length > 0) {
    await prisma.isBasvurusu.deleteMany({ where: { isIlaniId: { in: eskiIlanlar.map((i) => i.id) } } });
    await prisma.isIlani.deleteMany({ where: { id: { in: eskiIlanlar.map((i) => i.id) } } });
    console.log(`Önceki seed kaydı temizlendi: ${eskiIlanlar.length} ilan (+ bağlı başvurular).`);
  }

  const olusturulanIlanlar = [];
  for (const ilan of ilanlar) {
    const firmaId = firmaIdAdaGore.get(ilan.firmaAdi);
    const olusturanKullaniciId = firmaId ? yetkiliIdFirmaIdGore.get(firmaId) : undefined;
    if (!firmaId || !olusturanKullaniciId) continue;
    const olusturulan = await prisma.isIlani.create({
      data: {
        firmaId,
        olusturanKullaniciId,
        baslik: ilan.baslik,
        aciklama: ilan.aciklama,
        konum: ilan.konum,
        durum: ilan.durum,
      },
    });
    olusturulanIlanlar.push(olusturulan);
  }
  console.log(`${olusturulanIlanlar.length} iş ilanı oluşturuldu.`);

  // Başvuru sahibi 4 aday hesabı — ziyaretçi rolünde, upsert (email unique).
  const adaylar = [
    { email: 'aday.mehmet@example.com', ad: 'Mehmet', soyad: 'Yılmaz' },
    { email: 'aday.ayse@example.com', ad: 'Ayşe', soyad: 'Demir' },
    { email: 'aday.can@example.com', ad: 'Can', soyad: 'Kaya' },
    { email: 'aday.zeynep@example.com', ad: 'Zeynep', soyad: 'Şahin' },
  ];
  const adayKullanicilari = [];
  for (const aday of adaylar) {
    const kullanici = await prisma.kullanici.upsert({
      where: { email: aday.email },
      update: {},
      create: { ...aday, sifreHash, rol: 'ziyaretci', epostaDogrulandi: true },
    });
    adayKullanicilari.push(kullanici);
  }

  // İlk ilana (Depo Sorumlusu, aktif) 4 örnek başvuru — `IsBasvurusuDurumu`
  // enum'ının 4 değeri de temsil ediliyor ki başvurular ekranındaki renkli
  // etiketlerin (beklemede/incelendi/reddedildi/kabul) hepsi görülebilsin.
  const hedefIlan = olusturulanIlanlar[0];
  if (hedefIlan) {
    await prisma.isBasvurusu.createMany({
      data: [
        { isIlaniId: hedefIlan.id, kullaniciId: adayKullanicilari[0].id, durum: 'beklemede' },
        { isIlaniId: hedefIlan.id, kullaniciId: adayKullanicilari[1].id, durum: 'incelendi' },
        { isIlaniId: hedefIlan.id, kullaniciId: adayKullanicilari[2].id, durum: 'reddedildi' },
        { isIlaniId: hedefIlan.id, kullaniciId: adayKullanicilari[3].id, durum: 'kabul' },
      ],
    });
    console.log('4 iş başvurusu oluşturuldu.');
  }

  console.log(
    `Test hesapları (şifre: ${SEED_SIFRE}): ${firmaYetkilileri.map((f) => f.email).join(', ')} (firma_yetkilisi), ` +
      `${adaylar.map((a) => a.email).join(', ')} (ziyaretçi/aday).`,
  );
}

/**
 * Cookzone: 1 işletme (+ bağlı bölge noktası), birkaç menü öğesi, 1
 * cookzone_yetkilisi hesabı. Firma modülündeki gibi bağımlıları FK sırasına
 * göre temizleyip yeniden yazıyor (idempotent).
 */
async function cookzoneYaz() {
  console.log('Cookzone seed verisi yazılıyor...');

  const eskiIsletme = await prisma.cookzoneIsletme.findFirst({ where: { ad: 'Ana Kafeterya' } });
  if (eskiIsletme) {
    await prisma.cookzoneSiparisKalemi.deleteMany({ where: { siparis: { isletmeId: eskiIsletme.id } } });
    await prisma.cookzoneSiparis.deleteMany({ where: { isletmeId: eskiIsletme.id } });
    await prisma.cookzoneMenuOgesi.deleteMany({ where: { isletmeId: eskiIsletme.id } });
    await prisma.kullanici.updateMany({
      where: { cookzoneIsletmeId: eskiIsletme.id },
      data: { cookzoneIsletmeId: null },
    });
    await prisma.cookzoneIsletme.delete({ where: { id: eskiIsletme.id } });
  }
  await prisma.bolgeNoktasi.deleteMany({ where: { ad: 'Ana Kafeterya' } });

  const bolgeNoktasi = await prisma.bolgeNoktasi.create({
    data: { ad: 'Ana Kafeterya', tur: 'ortak_alan', enlem: 41.2772, boylam: 27.8097 },
  });

  const isletme = await prisma.cookzoneIsletme.create({
    data: { ad: 'Ana Kafeterya', bolgeNoktasiId: bolgeNoktasi.id },
  });

  await prisma.cookzoneMenuOgesi.createMany({
    data: [
      // Ana Yemek
      {
        isletmeId: isletme.id,
        ad: 'Izgara Tavuk Menü',
        aciklama: 'Pilav ve mevsim salatası ile',
        fiyat: 95,
        kategori: 'Ana Yemek',
      },
      {
        isletmeId: isletme.id,
        ad: 'Köfte Menü',
        aciklama: 'Izgara köfte, pilav ve közlenmiş sebze',
        fiyat: 110,
        kategori: 'Ana Yemek',
      },
      {
        isletmeId: isletme.id,
        ad: 'Etli Güveç',
        aciklama: null,
        fiyat: 130,
        kategori: 'Ana Yemek',
      },
      // Çorba
      { isletmeId: isletme.id, ad: 'Mercimek Çorbası', aciklama: null, fiyat: 35, kategori: 'Çorba' },
      { isletmeId: isletme.id, ad: 'Ezogelin Çorbası', aciklama: null, fiyat: 35, kategori: 'Çorba' },
      { isletmeId: isletme.id, ad: 'Yayla Çorbası', aciklama: null, fiyat: 35, kategori: 'Çorba' },
      // Başlangıç
      { isletmeId: isletme.id, ad: 'Humus Tabağı', aciklama: 'Zeytinyağlı, lavaş ile', fiyat: 45, kategori: 'Başlangıç' },
      { isletmeId: isletme.id, ad: 'Sigara Böreği (6 adet)', aciklama: null, fiyat: 55, kategori: 'Başlangıç' },
      // Salata
      { isletmeId: isletme.id, ad: 'Mevsim Salata', aciklama: null, fiyat: 40, kategori: 'Salata' },
      { isletmeId: isletme.id, ad: 'Tavuklu Sezar Salata', aciklama: null, fiyat: 75, kategori: 'Salata' },
      // Tostlar
      { isletmeId: isletme.id, ad: 'Kaşarlı Tost', aciklama: null, fiyat: 50, kategori: 'Tostlar' },
      { isletmeId: isletme.id, ad: 'Karışık Tost', aciklama: 'Kaşar, sucuk, domates', fiyat: 65, kategori: 'Tostlar' },
      // Hamburgerler
      { isletmeId: isletme.id, ad: 'Klasik Burger', aciklama: 'Dana köfte, cheddar, marul, domates', fiyat: 120, kategori: 'Hamburgerler' },
      { isletmeId: isletme.id, ad: 'Tavuk Burger', aciklama: null, fiyat: 105, kategori: 'Hamburgerler' },
      // İçecek
      { isletmeId: isletme.id, ad: 'Ayran', aciklama: null, fiyat: 15, kategori: 'İçecek' },
      { isletmeId: isletme.id, ad: 'Kola', aciklama: null, fiyat: 25, kategori: 'İçecek' },
      { isletmeId: isletme.id, ad: 'Türk Kahvesi', aciklama: null, fiyat: 30, kategori: 'İçecek' },
      { isletmeId: isletme.id, ad: 'Çay', aciklama: null, fiyat: 10, kategori: 'İçecek' },
      // Tatlı
      { isletmeId: isletme.id, ad: 'Künefe', aciklama: null, fiyat: 60, kategori: 'Tatlı' },
      { isletmeId: isletme.id, ad: 'Sütlaç', aciklama: null, fiyat: 40, kategori: 'Tatlı' },
    ],
  });

  const sifreHash = await bcrypt.hash(SEED_SIFRE, 10);
  await prisma.kullanici.upsert({
    where: { email: 'yetkili.cookzone@example.com' },
    update: { cookzoneIsletmeId: isletme.id, rol: 'cookzone_yetkilisi' },
    create: {
      email: 'yetkili.cookzone@example.com',
      sifreHash,
      ad: 'Cookzone',
      soyad: 'Yetkilisi',
      rol: 'cookzone_yetkilisi',
      cookzoneIsletmeId: isletme.id,
      epostaDogrulandi: true,
    },
  });

  const menuSayisi = await prisma.cookzoneMenuOgesi.count({ where: { isletmeId: isletme.id } });
  console.log(`Cookzone işletmesi + ${menuSayisi} menü öğesi oluşturuldu.`);
  console.log(`Test hesabı (şifre: ${SEED_SIFRE}): yetkili.cookzone@example.com (cookzone_yetkilisi).`);
}

/**
 * Palet Tesisi yönetim ekranını test edebilecek bir hesap — cookzoneYaz()'ın
 * aksine bağlanacak bir "işletme" yok (bölgede tek bir palet tesisi var,
 * Firma/CookzoneIsletme gibi ayrı bir tablo gerekmiyor), o yüzden sadece
 * rol ataması yeterli.
 */
async function paletTesisiYetkilisiYaz() {
  const sifreHash = await bcrypt.hash(SEED_SIFRE, 10);
  await prisma.kullanici.upsert({
    where: { email: 'yetkili.palettesisi@example.com' },
    update: { rol: 'palet_tesisi_yetkilisi' },
    create: {
      email: 'yetkili.palettesisi@example.com',
      sifreHash,
      ad: 'Palet Tesisi',
      soyad: 'Yetkilisi',
      rol: 'palet_tesisi_yetkilisi',
      epostaDogrulandi: true,
    },
  });
  console.log(`Test hesabı (şifre: ${SEED_SIFRE}): yetkili.palettesisi@example.com (palet_tesisi_yetkilisi).`);
}

/**
 * Ana Sayfa → "Dış Tedarikçi ve Hizmetler" bölümü. Diğer seed verilerinden
 * FARKLI olarak bunlar UYDURMA değil — Berzan'ın 13.08.2026'da gönderdiği
 * gerçek logo dosyaları. Dosyalar `prisma/seed-assets/is-ortaklari/` altında
 * git'e giriyor (uploads/ .gitignore'lu olduğu için orada tutulamazlar),
 * her seed çalıştığında `uploads/`'a kopyalanıp LocalFileStorageAdapter'ın
 * ürettiği URL biçimiyle (`/uploads/<dosya>`) kaydediliyor.
 */
async function isOrtaklariniYaz() {
  const ortaklar = [
    { ad: 'Halkbank', dosyaAdi: 'is-ortagi-halkbank.webp', kategori: 'Bankacılık' },
    { ad: 'Aras Kargo', dosyaAdi: 'is-ortagi-araskargo.jpg', kategori: 'Kargo ve Lojistik' },
    { ad: 'netelsan', dosyaAdi: 'is-ortagi-netelsan.jpg', kategori: 'Güvenlik Teknolojileri' },
    { ad: 'Kärcher', dosyaAdi: 'is-ortagi-karcher.webp', kategori: 'Temizlik Ekipmanları' },
    { ad: 'Brisa', dosyaAdi: 'is-ortagi-brisa.webp', kategori: 'Otomotiv ve Lastik' },
  ];

  mkdirSync(UPLOADS_DIR, { recursive: true });
  for (const { dosyaAdi } of ortaklar) {
    copyFileSync(join(SEED_ASSETS_DIR, 'is-ortaklari', dosyaAdi), join(UPLOADS_DIR, dosyaAdi));
  }

  const kayitlar = ortaklar.map(({ ad, dosyaAdi, kategori }) => ({ ad, logoUrl: `/uploads/${dosyaAdi}`, kategori }));

  const adlar = kayitlar.map((o) => o.ad);
  const { count: silinen } = await prisma.isOrtagi.deleteMany({ where: { ad: { in: adlar } } });
  if (silinen > 0) {
    console.log(`Önceki seed kaydı temizlendi: ${silinen} iş ortağı.`);
  }

  await prisma.isOrtagi.createMany({ data: kayitlar });
  console.log(`${kayitlar.length} iş ortağı oluşturuldu.`);
}

/**
 * Acil Durum ana ekranındaki 6 birim (13.08.2026, Berzan'ın paylaştığı
 * mockup). Telefon numaraları mockup'ta da açıkça "örnek olarak verilmiştir"
 * diye not düşülmüş — ASB gerçek numaraları bildirdiğinde burada
 * güncellenecek, upsert olduğu için tek satır değişikliği yeterli olacak.
 * `tur` @unique olduğu için upsert — deleteMany/createMany yerine, çünkü
 * bu birimler AcilDurumBildirimi'nden FK ile referans alınabilir (bolgeNoktasi
 * gibi değil ama ileride alınabilir), silip yeniden yaratmak riskli olurdu.
 */
async function acilDurumBilgileriniYaz() {
  const birimler = [
    {
      tur: 'isg',
      telefon: '0282 691 11 04',
      telefon2: null,
      eposta: 'info@tekinisg.com.tr',
      adres: 'Karamehmet Mah. Avrupa Serbest Bölgesi 59930 Ergene / Tekirdağ',
      aciklama: 'İş sağlığı ve güvenliği ile ilgili her türlü bilgi, destek ve yönlendirme için Tekin İSG birimi ile iletişime geçebilirsiniz.',
      calismaSaatleri: null,
    },
    {
      tur: 'itfaiye',
      // '112' bilerek burada YOK — evrensel/sabit bir numara, uygulama
      // tarafında donanımsal bir sabit olarak tutuluyor (birim_detay_ekrani.dart),
      // burada sadece birimin DOĞRUDAN hattı var.
      telefon: '0282 676 12 10',
      telefon2: null,
      eposta: null,
      adres: 'Avrupa Serbest Bölgesi İtfaiye Birimi 59930 Ergene / Tekirdağ',
      aciklama: 'Yangın, patlama, sızıntı ve benzeri acil durumlarda 112\'yi arayarak itfaiye birimine ulaşabilirsiniz.',
      calismaSaatleri: null,
    },
    {
      tur: 'guvenlik',
      telefon: '0282 676 10 10',
      telefon2: '0549 676 10 10',
      eposta: null,
      adres: 'Avrupa Serbest Bölgesi Güvenlik Müdürlüğü 59930 Ergene / Tekirdağ',
      aciklama: 'Güvenlik ile ilgili her türlü ihbar ve destek için 7/24 güvenlik birimi ile iletişime geçebilirsiniz.',
      calismaSaatleri: null,
    },
    {
      tur: 'musteri_hizmetleri',
      telefon: '0282 676 10 00',
      telefon2: null,
      eposta: 'info@asb.com.tr',
      adres: null,
      aciklama: 'ASB ile ilgili her türlü talep, öneri ve bilgi için müşteri hizmetleri birimimizle iletişime geçebilirsiniz.',
      calismaSaatleri: 'Hafta içi 08:30 - 17:30, Cumartesi 08:30 - 13:00',
    },
    {
      tur: 'kantar',
      telefon: '0282 676 11 30',
      telefon2: null,
      eposta: null,
      adres: 'Avrupa Serbest Bölgesi Kantar Birimi 59930 Ergene / Tekirdağ',
      aciklama: 'Araç/yük tartım işlemleri için kantar birimi ile iletişime geçebilirsiniz.',
      calismaSaatleri: 'Hafta içi 08:30 - 17:30, Cumartesi 08:30 - 13:00',
    },
    {
      tur: 'gumruk',
      telefon: '0282 676 11 20',
      telefon2: null,
      eposta: null,
      adres: 'ASB Gümrük Müdürlüğü 59930 Ergene / Tekirdağ',
      aciklama: 'Gümrük işlemleri ve evrak süreçleri ile ilgili bilgi almak için iletişime geçebilirsiniz.',
      calismaSaatleri: 'Hafta içi 08:30 - 17:30, Cumartesi Kapalı',
    },
  ];

  for (const birim of birimler) {
    await prisma.acilDurumBilgisi.upsert({
      where: { tur: birim.tur },
      update: birim,
      create: birim,
    });
  }
  console.log(`${birimler.length} acil durum birimi bilgisi yazıldı.`);
}

/**
 * Toplanma Alanları listesi. Koordinatlar (enlem/boylam) BİLEREK 0,0 —
 * gerçek konum entegrasyonu bu iş kapsamının dışında bırakıldı
 * (13.08.2026, Berzan: "konum hariç kalanını yap, konum şu anlık kalsın"),
 * "Haritada Göster" butonu yine de çalışır ama gerçek olmayan bir noktaya
 * gider. Gerçek koordinatlar netleşince tek satırlık bir güncelleme yeterli.
 */
async function toplanmaAlanlariniYaz() {
  const alanlar = [
    { ad: 'Toplanma Alanı 1', aciklama: 'Ana Bina Arkası Otopark. Detaylı konum haritada gösterilmektedir.', enlem: 0, boylam: 0, sira: 1 },
    { ad: 'Toplanma Alanı 2', aciklama: 'Lojistik Depo Yanı. Detaylı konum haritada gösterilmektedir.', enlem: 0, boylam: 0, sira: 2 },
    { ad: 'Toplanma Alanı 3', aciklama: 'Güney Kapı Yanı. Detaylı konum haritada gösterilmektedir.', enlem: 0, boylam: 0, sira: 3 },
  ];

  const adlar = alanlar.map((a) => a.ad);
  await prisma.toplanmaAlani.deleteMany({ where: { ad: { in: adlar } } });
  await prisma.toplanmaAlani.createMany({ data: alanlar });
  console.log(`${alanlar.length} toplanma alanı yazıldı.`);
}

/**
 * Acil Durum bildirimlerinin yönlendirildiği 6 ekip hesabı (14.08.2026).
 * `tekin_isg_ekibi` (dış/anlaşmalı sağlık-güvenlik firması) ile
 * `sirket_isg_ekibi` (ASB'nin kendi iç İSG ekibi) BİLEREK ayrı hesaplar.
 */
async function acilDurumEkipleriniYaz() {
  const sifreHash = await bcrypt.hash(SEED_SIFRE, 10);
  const ekipler: { email: string; ad: string; rol: KullaniciRolu }[] = [
    { email: 'ekip.itfaiye@example.com', ad: 'İtfaiye', rol: KullaniciRolu.itfaiye_ekibi },
    { email: 'ekip.guvenlik@example.com', ad: 'Güvenlik', rol: KullaniciRolu.guvenlik_ekibi },
    { email: 'ekip.tekinisg@example.com', ad: 'Tekin İSG', rol: KullaniciRolu.tekin_isg_ekibi },
    { email: 'ekip.kantar@example.com', ad: 'Kantar', rol: KullaniciRolu.kantar_ekibi },
    { email: 'ekip.gumruk@example.com', ad: 'Gümrük', rol: KullaniciRolu.gumruk_ekibi },
    { email: 'ekip.sirketisg@example.com', ad: 'Şirket İSG', rol: KullaniciRolu.sirket_isg_ekibi },
  ];

  for (const ekip of ekipler) {
    await prisma.kullanici.upsert({
      where: { email: ekip.email },
      update: { rol: ekip.rol },
      create: {
        email: ekip.email,
        sifreHash,
        ad: ekip.ad,
        soyad: 'Ekibi',
        rol: ekip.rol,
        epostaDogrulandi: true,
      },
    });
  }
  console.log(
    `Test hesapları (şifre: ${SEED_SIFRE}): ${ekipler.map((e) => e.email).join(', ')} (acil durum ekipleri).`,
  );
}

main()
  .catch((hata) => {
    console.error(hata);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
