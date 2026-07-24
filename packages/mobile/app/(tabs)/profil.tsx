import { Pressable, StyleSheet, Text, View } from 'react-native';
import { Link } from 'expo-router';
import { useAuthStore } from '../../src/core/stores';

export default function ProfilScreen() {
  const { kullanici, cikisYap } = useAuthStore();

  if (!kullanici) {
    return (
      <View style={styles.container}>
        <Text style={styles.baslik}>Profil</Text>
        <Text style={styles.aciklama}>Devam etmek için giriş yapın.</Text>
        <Link href="/giris" style={styles.link}>Giriş Yap</Link>
        <Link href="/kayit" style={styles.link}>Kayıt Ol</Link>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.baslik}>{kullanici.ad} {kullanici.soyad}</Text>
      <Text style={styles.aciklama}>{kullanici.email}</Text>
      <Text style={styles.aciklama}>Rol: {kullanici.rol}</Text>
      <Pressable style={styles.buton} onPress={cikisYap}>
        <Text style={styles.butonYazi}>Çıkış Yap</Text>
      </Pressable>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center', gap: 8, padding: 24 },
  baslik: { fontSize: 24, fontWeight: 'bold' },
  aciklama: { color: '#555' },
  link: { color: '#1d4ed8', fontSize: 16, marginTop: 4 },
  buton: { backgroundColor: '#dc2626', borderRadius: 8, padding: 12, marginTop: 16 },
  butonYazi: { color: '#fff', fontWeight: 'bold' },
});