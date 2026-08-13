// AdminJS'in varsayılan giriş sayfasını (adminjs/src/frontend/components/
// login/index.tsx) `componentLoader.override('Login', ...)` ile değiştiriyor
// — sebebi: uygulamanın kendi giriş ekranındaki (SifreGozu, bkz.
// core/widgets/form_ogeleri.dart) "şifreyi göster/gizle" göz simgesi burada
// yok, Berzan'ın isteği bu. gosterge-paneli.jsx'teki gerekçeyle AYNI sebeple
// bilerek `src/` DIŞINDA: backend'in tsconfig'i JSX/React tipini tanımıyor,
// bu dosya AdminJS'in kendi rollup tabanlı bileşen derleyicisiyle ayrıca
// bundle'lanıyor (kaynağı admin-panel.module.ts'teki ComponentLoader.add()).
//
// `action`/`errorMessage` login-template.tsx'in `window.__APP_STATE__`e
// yazdığı değerler — orijinal bileşenin okuduğu YER birebir aynı.

import React, { useState } from 'react';
import { Box, Button, FormGroup, H5, Icon, Input, Label, MessageBox, Text } from '@adminjs/design-system';
import { useSelector } from 'react-redux';
import { useTranslation } from 'adminjs';

const GirisSayfasi = () => {
  const props = (typeof window !== 'undefined' && window.__APP_STATE__) || {};
  const { action, errorMessage: message } = props;
  const { translateComponent, translateMessage } = useTranslation();
  const branding = useSelector((state) => state.branding);
  const [sifreGorunur, setSifreGorunur] = useState(false);

  return (
    <Box
      flex
      variant="grey"
      alignItems="center"
      justifyContent="center"
      flexDirection="column"
      height="100vh"
    >
      <Box
        as="form"
        action={action}
        method="POST"
        bg="white"
        boxShadow="login"
        p="x3"
        width={['100%', '100%', '420px']}
        borderRadius="lg"
      >
        <H5 marginBottom="xxl">{branding && branding.companyName ? branding.companyName : 'ASB Platform'}</H5>
        {message && (
          <MessageBox
            my="lg"
            message={message.split(' ').length > 1 ? message : translateMessage(message)}
            variant="danger"
          />
        )}
        <FormGroup>
          <Label required>{translateComponent('Login.properties.email')}</Label>
          <Input name="email" placeholder={translateComponent('Login.properties.email')} width="100%" />
        </FormGroup>
        <FormGroup>
          <Label required>{translateComponent('Login.properties.password')}</Label>
          <Box position="relative">
            <Input
              type={sifreGorunur ? 'text' : 'password'}
              name="password"
              placeholder={translateComponent('Login.properties.password')}
              autoComplete="current-password"
              width="100%"
              pr="40px"
            />
            <Box
              as="button"
              type="button"
              onClick={() => setSifreGorunur((oncekiDeger) => !oncekiDeger)}
              aria-label={sifreGorunur ? 'Şifreyi gizle' : 'Şifreyi göster'}
              position="absolute"
              top="0"
              right="0"
              bottom="0"
              width="40px"
              bg="transparent"
              border="none"
              style={{ cursor: 'pointer' }}
              flex
              alignItems="center"
              justifyContent="center"
            >
              <Icon icon={sifreGorunur ? 'EyeOff' : 'Eye'} color="grey60" />
            </Box>
          </Box>
        </FormGroup>
        <Text mt="xl" textAlign="center">
          <Button variant="contained">{translateComponent('Login.loginButton')}</Button>
        </Text>
      </Box>
    </Box>
  );
};

export default GirisSayfasi;
