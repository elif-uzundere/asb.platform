import { useState } from 'react';
import { Alert, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { Link, router } from 'expo-router';
import { useAuthStore } from '../src/core/stores';

export default function KayitScreen() {
  const kayitOl = useAuthStore((s) => s.kayitOl);
  const [ad, setAd] = useState('');
  const [soyad, setSoyad] = useState('');
  const [email, setEmail] = useState('');
  const [sifre, setSifre] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);

  const gonder = async () => {
    setYukleniyor(true);
    try {
      await kayitOl({ ad, soyad, email, sifre });
      router.replace('/(tabs)');
    } catch {
      Alert.alert('Kayıt başarısız', 'Bilgileri kontrol edin (şifre: en az 8 karakter, 1 rakam). E-posta zaten kayıtlı olabilir.');
    } finally {
      setYukleniyor(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.baslik}>Kayıt Ol</Text>
      <TextInput style={styles.input} placeholder="Ad" value={ad} onChangeText={setAd} />
      <TextInput style={styles.input} placeholder="Soyad" value={soyad} onChangeText={setSoyad} />
      <TextInput
        style={styles.input}
        placeholder="E-posta"
        autoCapitalize="none"
        keyboardType="email-address"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        style={styles.input}
        placeholder="Şifre (min 8 karakter, 1 rakam)"
        secureTextEntry
        value={sifre}
        onChangeText={setSifre}
      />
      <Pressable style={styles.buton} onPress={gonder} disabled={yukleniyor}>
        <Text style={styles.butonYazi}>{yukleniyor ? 'Kaydediliyor...' : 'Kayıt Ol'}</Text>
      </Pressable>
      <Link href="/giris" style={styles.link}>Zaten hesabın var mı? Giriş yap</Link>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', padding: 24, gap: 12 },
  baslik: { fontSize: 28, fontWeight: 'bold', marginBottom: 12, textAlign: 'center' },
  input: { borderWidth: 1, borderColor: '#ccc', borderRadius: 8, padding: 12 },
  buton: { backgroundColor: '#1d4ed8', borderRadius: 8, padding: 14, alignItems: 'center' },
  butonYazi: { color: '#fff', fontWeight: 'bold' },
  link: { textAlign: 'center', color: '#1d4ed8', marginTop: 8 },
});