import { useState } from 'react';
import {
  Alert,
  Image,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';
import { Link, router } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '../src/core/stores';
import { renkler } from '../src/core/theme/renkler';

export default function GirisScreen() {
  const girisYap = useAuthStore((s) => s.girisYap);
  const [email, setEmail] = useState('');
  const [sifre, setSifre] = useState('');
  const [sifreGoster, setSifreGoster] = useState(false);
  const [beniHatirla, setBeniHatirla] = useState(false);
  const [yukleniyor, setYukleniyor] = useState(false);

  const gonder = async () => {
    setYukleniyor(true);
    try {
      await girisYap({ email, sifre, beniHatirla });
      router.replace('/(tabs)');
    } catch {
      Alert.alert('Giriş başarısız', 'E-posta veya şifre hatalı.');
    } finally {
      setYukleniyor(false);
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.kaydirici} keyboardShouldPersistTaps="handled">
      <View style={styles.icerik}>
        <Image
          source={require('../assets/images/giris-hero.jpeg')}
          style={styles.hero}
          resizeMode="cover"
        />

        <View style={styles.kart}>
          <Text style={styles.baslik}>Hoş geldiniz!</Text>
          <Text style={styles.altBaslik}>
            Hesabınıza giriş yaparak tüm hizmetlerimize kolayca ulaşabilirsiniz.
          </Text>

          <View style={styles.girdiKutusu}>
            <Ionicons name="person-outline" size={18} color={renkler.metinIkincil} />
            <TextInput
              style={styles.girdi}
              placeholder="E-posta veya telefon"
              autoCapitalize="none"
              keyboardType="email-address"
              value={email}
              onChangeText={setEmail}
            />
          </View>

          <View style={styles.girdiKutusu}>
            <Ionicons name="lock-closed-outline" size={18} color={renkler.metinIkincil} />
            <TextInput
              style={styles.girdi}
              placeholder="Şifre"
              secureTextEntry={!sifreGoster}
              value={sifre}
              onChangeText={setSifre}
            />
            <Pressable onPress={() => setSifreGoster((v) => !v)}>
              <Ionicons
                name={sifreGoster ? 'eye-off-outline' : 'eye-outline'}
                size={18}
                color={renkler.metinIkincil}
              />
            </Pressable>
          </View>

          <View style={styles.altSatir}>
            <Pressable style={styles.hatirlaSatiri} onPress={() => setBeniHatirla((v) => !v)}>
              <Ionicons
                name={beniHatirla ? 'checkbox' : 'square-outline'}
                size={18}
                color={renkler.lacivert}
              />
              <Text style={styles.hatirlaYazi}>Beni hatırla</Text>
            </Pressable>
            <Pressable onPress={() => Alert.alert('Yakında', 'Şifre sıfırlama henüz eklenmedi.')}>
              <Text style={styles.unuttumYazi}>Şifremi unuttum?</Text>
            </Pressable>
          </View>

          <Pressable style={styles.buton} onPress={gonder} disabled={yukleniyor}>
            <Text style={styles.butonYazi}>{yukleniyor ? 'Giriş yapılıyor...' : 'Giriş yap'}</Text>
          </Pressable>

          <Text style={styles.veyaYazi}>veya</Text>

          <View style={styles.sosyalSatiri}>
            {(['logo-google', 'logo-linkedin', 'logo-apple'] as const).map((ikon) => (
              <Pressable
                key={ikon}
                style={styles.sosyalButon}
                onPress={() => Alert.alert('Yakında', 'Sosyal giriş henüz eklenmedi.')}
              >
                <Ionicons name={ikon} size={20} color={renkler.lacivert} />
              </Pressable>
            ))}
          </View>

          <View style={styles.kayitSatiri}>
            <Text style={styles.altBaslik}>Hesabınız yok mu? </Text>
            <Link href="/kayit" style={styles.kayitLink}>Kayıt ol</Link>
          </View>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  kaydirici: { flexGrow: 1, backgroundColor: renkler.beyaz },
  icerik: Platform.OS === 'web' ? { width: '100%', maxWidth: 430, alignSelf: 'center' } : {},
  hero: { width: '100%', height: 380 },
  kart: {
    marginTop: -28,
    backgroundColor: renkler.beyaz,
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    padding: 24,
    gap: 14,
  },
  baslik: { fontSize: 20, fontWeight: '500', textAlign: 'center', color: renkler.lacivert },
  altBaslik: { fontSize: 13, color: renkler.metinIkincil, textAlign: 'center' },
  girdiKutusu: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
    borderWidth: 1,
    borderColor: renkler.kenarlik,
    borderRadius: 10,
    paddingHorizontal: 14,
    height: 46,
  },
  girdi: { flex: 1, fontSize: 14, outlineStyle: 'none' } as never,
  altSatir: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  hatirlaSatiri: { flexDirection: 'row', alignItems: 'center', gap: 6 },
  hatirlaYazi: { fontSize: 12, color: renkler.metinIkincil },
  unuttumYazi: { fontSize: 12, color: renkler.mavi },
  buton: {
    backgroundColor: renkler.lacivert,
    borderRadius: 10,
    height: 48,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 4,
  },
  butonYazi: { color: renkler.beyaz, fontWeight: '500', fontSize: 15 },
  veyaYazi: { textAlign: 'center', fontSize: 12, color: renkler.metinIkincil },
  sosyalSatiri: { flexDirection: 'row', justifyContent: 'center', gap: 16 },
  sosyalButon: {
    width: 44,
    height: 44,
    borderRadius: 22,
    borderWidth: 1,
    borderColor: renkler.kenarlik,
    alignItems: 'center',
    justifyContent: 'center',
  },
  kayitSatiri: { flexDirection: 'row', justifyContent: 'center', marginTop: 4 },
  kayitLink: { fontSize: 13, color: renkler.mavi, fontWeight: '500' },
});