// AdminJS'in kendi rollup/babel tabanlı bileşen derleyicisi tarafından
// bundle'lanır — bu dosya bilerek `src/` DIŞINDA: backend'in kendi
// `tsconfig.json`'ı `include: ["src/**/*"]` ile sınırlı, JSX/React tipi de
// yok. `src/` içine konsaydı hem tsc hem eslint bunu TypeScript dosyası
// sanıp derleme/lint hatası verirdi. Kaynağı admin-panel.module.ts'teki
// dinamik ComponentLoader.add() çağrısı gösteriyor.
//
// AdminJS özel dashboard bileşenlerine `adminJsOptions.dashboard.handler`ın
// döndürdüğü veriyi PROP OLARAK GEÇMİYOR (bkz. adminjs/lib/frontend/
// components/routes/dashboard.js — bileşen prop'suz render ediliyor).
// Veri, bileşenin kendisinin `ApiClient().getDashboard()` ile ayrıca
// çekmesi gereken bir uçtan geliyor — bu yüzden aşağıda useEffect var.

import React, { useEffect, useState } from 'react';
import { Box, H2, H4, Text, Icon } from '@adminjs/design-system';
import { ApiClient } from 'adminjs';

const api = new ApiClient();

const Kart = ({ baslik, deger, ikon, renk }) => (
  <Box
    variant="white"
    boxShadow="card"
    width={1 / 4}
    p="xl"
    mr="lg"
    mb="lg"
    borderRadius="lg"
    flex
    flexDirection="column"
  >
    <Box mb="default">
      <Icon icon={ikon} size={28} color={renk} />
    </Box>
    <H2 mb="sm">{deger}</H2>
    <Text color="grey60">{baslik}</Text>
  </Box>
);

const GostergePaneli = () => {
  const [veri, setVeri] = useState(null);

  useEffect(() => {
    api.getDashboard().then((response) => setVeri(response.data));
  }, []);

  if (!veri) {
    return (
      <Box height="100vh" flex alignItems="center" justifyContent="center">
        <Text>Yükleniyor...</Text>
      </Box>
    );
  }

  const { bekleyenFirma, toplamFirma, toplamDuyuru, toplamKullanici, aktifBanner } = veri;

  return (
    <Box variant="grey">
      <Box maxWidth={1200} m="0 auto" p="xl">
        <H4 mb="xl">ASB Platform — Yönetim Özeti</H4>
        <Box flex flexWrap="wrap" flexDirection="row">
          <Kart
            baslik="Onay Bekleyen Firma"
            deger={bekleyenFirma}
            ikon="AlertCircle"
            renk={bekleyenFirma > 0 ? '#D97706' : '#059669'}
          />
          <Kart baslik="Toplam Firma" deger={toplamFirma} ikon="Briefcase" renk="#042C53" />
          <Kart baslik="Yayındaki Duyuru" deger={toplamDuyuru} ikon="Bell" renk="#042C53" />
          <Kart baslik="Kayıtlı Kullanıcı" deger={toplamKullanici} ikon="Users" renk="#042C53" />
        </Box>
        {bekleyenFirma > 0 && (
          <Box variant="white" boxShadow="card" p="xl" borderRadius="lg" mt="lg">
            <Text>
              <strong>{bekleyenFirma}</strong> firma onay bekliyor — sol menüden{' '}
              <strong>Firma Yönetimi</strong>'ne geçip onaylayabilir ya da reddedebilirsin.
            </Text>
          </Box>
        )}
        <Box mt="lg">
          <Text color="grey40" fontSize="sm">
            Aktif banner sayısı: {aktifBanner}
          </Text>
        </Box>
      </Box>
    </Box>
  );
};

export default GostergePaneli;
