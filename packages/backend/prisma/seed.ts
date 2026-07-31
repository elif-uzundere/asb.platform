// Geliştirme/test verisi. `npx prisma db seed` ile çalışır (ts-node üzerinden;
// bkz. package.json → prisma.seed). Tip denetimi prisma/tsconfig.json ile.
//
// TEKRAR ÇALIŞTIRILABİLİR (idempotent): her çalıştırmada kendi eklediği
// kayıtları önce adlarına göre siler, sonra yeniden yazar. Böylece 3 kez
// çalıştırınca 24 satır oluşmaz. Seed dışındaki firmalara DOKUNMAZ.

import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Firma seed verisi yazılıyor...');

  const firmalar = [
    {
      ad: 'Ege Lojistik A.Ş.',
      sektor: 'Lojistik',
      adres: 'Serbest Bölge, 3. Cadde No:12',
      telefon: '02321234567',
      eposta: 'info@egelojistik.com',
      onayDurumu: 'onaylandi' as const,
    },
    {
      ad: 'Anadolu Tekstil San. ve Tic. Ltd. Şti.',
      sektor: 'Tekstil',
      adres: 'Serbest Bölge, 5. Cadde No:8',
      telefon: '02327654321',
      eposta: 'iletisim@anadolutekstil.com',
      onayDurumu: 'onaylandi' as const,
    },
    {
      ad: 'Marmara Elektronik Yazılım A.Ş.',
      sektor: 'Elektronik',
      adres: 'Serbest Bölge, 2. Cadde No:21',
      telefon: '02329876543',
      eposta: 'info@marmaraelektronik.com',
      onayDurumu: 'onaylandi' as const,
    },
    {
      ad: 'Karadeniz Gıda İhracat Ltd. Şti.',
      sektor: 'Gıda',
      adres: 'Serbest Bölge, 7. Cadde No:15',
      telefon: '02321122334',
      eposta: 'ihracat@karadenizgida.com',
      onayDurumu: 'onaylandi' as const,
    },
    {
      ad: 'Toros İnşaat Malzemeleri A.Ş.',
      sektor: 'İnşaat',
      adres: 'Serbest Bölge, 1. Cadde No:4',
      telefon: '02325566778',
      eposta: 'info@torosinsaat.com',
      onayDurumu: 'onaylandi' as const,
    },
    {
      ad: 'Akdeniz Kimya Sanayi Ltd. Şti.',
      sektor: 'Kimya',
      adres: 'Serbest Bölge, 6. Cadde No:19',
      telefon: '02323344556',
      eposta: 'info@akdenizkimya.com',
      onayDurumu: 'onaylandi' as const,
    },
    {
      // Onay bekleyen — listede GÖRÜNMEMELİ, filtre testi için
      ad: 'Yeni Nesil Teknoloji A.Ş.',
      sektor: 'Teknoloji',
      adres: 'Serbest Bölge, 4. Cadde No:9',
      telefon: '02327788990',
      eposta: 'info@yenineslteknoloji.com',
      onayDurumu: 'beklemede' as const,
    },
    {
      // Reddedilmiş — listede GÖRÜNMEMELİ, filtre testi için
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
  const adlar = firmalar.map((f) => f.ad);
  const { count: silinen } = await prisma.firma.deleteMany({
    where: { ad: { in: adlar } },
  });
  if (silinen > 0) {
    console.log(`Önceki seed kaydı temizlendi: ${silinen} satır.`);
  }

  await prisma.firma.createMany({ data: firmalar });

  console.log(`${firmalar.length} firma oluşturuldu.`);
}

main()
  .catch((hata) => {
    console.error(hata);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
