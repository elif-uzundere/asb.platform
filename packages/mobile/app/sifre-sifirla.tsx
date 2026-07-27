import { useState } from 'react';
import { Alert, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { router, useLocalSearchParams } from 'expo-router';
import { sifreSifirlaIstegi } from '../src/features/auth/auth.api';
import { renkler } from '../src/core/theme/renkler';

export default function SifreSifirlaScreen() {
  const params = useLocalSearchParams<{ token?: string }>();
  const [token, setToken] = useState(params.token ?? '');
  const [yeniSifre, setYeniSifre] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);

  const gonder = async () => {
    setYukleniyor(true);
    try {
      await sifreSifirlaIstegi({ token, yeniSifre });
      Alert.alert('Başarılı', 'Şifren güncellendi, şimdi giriş yapabilirsin.');
      router.replace('/giris');
    } catch {
      Alert.alert(
        'Hata',
        'Link geçersiz/süresi dolmuş olabilir ya da şifre kuralına uymuyor (min 8 karakter, 1 rakam).',
      );
    } finally {
      setYukleniyor(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.baslik}>Yeni şifre belirle</Text>
      <TextInput
        style={styles.girdi}
        placeholder="Sıfırlama kodu (e-postadaki linkten)"
        value={token}
        onChangeText={setToken}
      />
      <TextInput
        style={styles.girdi}
        placeholder="Yeni şifre"
        secureTextEntry
        value={yeniSifre}
        onChangeText={setYeniSifre}
      />
      <Pressable style={styles.buton} onPress={gonder} disabled={yukleniyor}>
        <Text style={styles.butonYazi}>{yukleniyor ? 'Kaydediliyor...' : 'Şifreyi güncelle'}</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', padding: 24, gap: 12 },
  baslik: { fontSize: 20, fontWeight: '500', textAlign: 'center', color: renkler.lacivert },
  girdi: {
    borderWidth: 1,
    borderColor: renkler.kenarlik,
    borderRadius: 10,
    height: 46,
    paddingHorizontal: 14,
    outlineStyle: 'none',
  } as never,
  buton: {
    backgroundColor: renkler.lacivert,
    borderRadius: 10,
    height: 48,
    alignItems: 'center',
    justifyContent: 'center',
  },
  butonYazi: { color: renkler.beyaz, fontWeight: '500', fontSize: 15 },
});