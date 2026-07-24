import { useState } from 'react';
import { Alert, Pressable, StyleSheet, Text, TextInput, View } from 'react-native';
import { Link, router } from 'expo-router';
import { useAuthStore } from '../src/core/stores';

export default function GirisScreen() {
  const girisYap = useAuthStore((s) => s.girisYap);
  const [email, setEmail] = useState('');
  const [sifre, setSifre] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);

  const gonder = async () => {
    setYukleniyor(true);
    try {
      await girisYap({ email, sifre });
      router.replace('/(tabs)');
    } catch {
      Alert.alert('Giriş başarısız', 'E-posta veya şifre hatalı.');
    } finally {
      setYukleniyor(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.baslik}>Giriş Yap</Text>
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
        placeholder="Şifre"
        secureTextEntry
        value={sifre}
        onChangeText={setSifre}
      />
      <Pressable style={styles.buton} onPress={gonder} disabled={yukleniyor}>
        <Text style={styles.butonYazi}>{yukleniyor ? 'Giriş yapılıyor...' : 'Giriş Yap'}</Text>
      </Pressable>
      <Link href="/kayit" style={styles.link}>Hesabın yok mu? Kayıt ol</Link>
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