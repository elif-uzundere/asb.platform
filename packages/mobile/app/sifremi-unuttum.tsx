import { useState } from 'react';
import { Alert, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { router } from 'expo-router';
import { sifremiUnuttumIstegi } from '../src/features/auth/auth.api';
import { renkler } from '../src/core/theme/renkler';

export default function SifremiUnuttumScreen() {
  const [email, setEmail] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);

  const gonder = async () => {
    setYukleniyor(true);
    try {
      await sifremiUnuttumIstegi({ email });
      Alert.alert(
        'E-posta gönderildi',
        'Sistemde bu e-posta kayıtlıysa, sıfırlama linki gönderildi.',
      );
      router.replace('/giris');
    } catch {
      Alert.alert('Hata', 'Bir şeyler ters gitti, tekrar dene.');
    } finally {
      setYukleniyor(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.baslik}>Şifreni mi unuttun?</Text>
      <Text style={styles.aciklama}>E-postanı gir, sıfırlama linki gönderelim.</Text>
      <TextInput
        style={styles.girdi}
        placeholder="E-posta"
        autoCapitalize="none"
        keyboardType="email-address"
        value={email}
        onChangeText={setEmail}
      />
      <Pressable style={styles.buton} onPress={gonder} disabled={yukleniyor}>
        <Text style={styles.butonYazi}>{yukleniyor ? 'Gönderiliyor...' : 'Sıfırlama linki gönder'}</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', padding: 24, gap: 12 },
  baslik: { fontSize: 20, fontWeight: '500', textAlign: 'center', color: renkler.lacivert },
  aciklama: { fontSize: 13, color: renkler.metinIkincil, textAlign: 'center', marginBottom: 8 },
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