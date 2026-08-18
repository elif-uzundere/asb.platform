// Tek dosya, tüm "görsel yükle" özel aksiyonları için ortak bileşen (Firma,
// Banner, İş Ortağı, Palet, Cookzone Menü Öğesi). AdminJS'in @adminjs/upload
// eklentisi ayrı key/bucket/mimeType alanları gerektiriyor — mevcut şemadaki
// tek `...Url` VarChar alanına uymuyor, bu yüzden bilerek kullanılmadı
// (18.08.2026). Onun yerine mevcut record action mekanizması (express-
// formidable @adminjs/express içine gömülü, bkz. buildRouter.ts) kullanılıyor:
// FormData ile bu action'a POST edilen dosya, backend'deki handler'da
// `request.payload.gorsel` olarak (formidable File objesi, `.path` geçici
// dosya konumu) karşılanıp `FileStoragePort.upload()`a veriliyor — uygulamanın
// geri kalanındaki (Palet Tesisi, İkinci El) yükleme akışıyla AYNI mekanizma.
import React, { useState } from 'react';
import { Box, Button, FormGroup, Label, Text } from '@adminjs/design-system';
import { ApiClient } from 'adminjs';

const api = new ApiClient();

const GorselYuklemeFormu = (props) => {
  const { record, resource, action } = props;
  const [dosya, setDosya] = useState(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState(null);

  const gonder = async () => {
    if (!dosya) {
      setHata('Önce bir görsel seçin.');
      return;
    }
    setYukleniyor(true);
    setHata(null);
    try {
      const formData = new FormData();
      formData.append('gorsel', dosya);
      await api.recordAction({
        resourceId: resource.id,
        recordId: record.id,
        actionName: action.name,
        data: formData,
      });
      window.location.reload();
    } catch (e) {
      setYukleniyor(false);
      setHata('Yükleme başarısız oldu, tekrar deneyin.');
    }
  };

  return (
    <Box variant="white" boxShadow="card" p="xl" borderRadius="lg" maxWidth={480} m="0 auto" mt="xl">
      <Text mb="lg" fontWeight="bold">
        Görsel Yükle
      </Text>
      <FormGroup>
        <Label>Dosya (jpeg/png/webp, en fazla 5 MB)</Label>
        <input
          type="file"
          accept="image/jpeg,image/png,image/webp"
          onChange={(e) => setDosya(e.target.files?.[0] ?? null)}
        />
      </FormGroup>
      {hata && (
        <Text color="danger" mb="default">
          {hata}
        </Text>
      )}
      <Button variant="primary" onClick={gonder} disabled={yukleniyor}>
        {yukleniyor ? 'Yükleniyor...' : 'Yükle'}
      </Button>
    </Box>
  );
};

export default GorselYuklemeFormu;
