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
import { kayitOlIstegi } from '../src/features/auth/auth.api';
import { renkler } from '../src/core/theme/renkler';

export default function KayitScreen() {
  const [ad, setAd] = useState('');
  const [soyad, setSoyad] = useState('');
  const [email, setEmail] = useState('');
  const [sifre, setSifre] = useState('');
  const [sifreGoster, setSifreGoster] = useState(false);
  const [yukleniyor, setYukleniyor] = useState(false);

  const gonder = async () => {
    setYukleniyor(true);
    try {
      await kayitOlIstegi({ ad, soyad, email, sifre });
      Alert.alert('Kayıt başarılı', 'Şimdi giriş yapabilirsiniz.');
      router.replace('/giris');
    } catch {
      Alert.alert(
        'Kayıt başarısız',
        'Bilgileri kontrol edin (şifre: en az 8 karakter, 1 rakam). E-posta zaten kayıtlı olabilir.',
      );
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
          <Text style={styles.baslik}>Hesap oluştur</Text>
          <Text style={styles.altBaslik}>
            Birkaç bilgiyle bölgenin tüm hizmetlerine erişin.
          </Text>

          <View style={styles.satir}>
            <View style={[styles.girdiKutusu, styles.yarim]}>
              <Ionicons name="person-outline" size={18} color={renkler.metinIkincil} />
              <TextInput
                style={styles.girdi}
                placeholder="Ad"
                value={ad}
                onChangeText={setAd}
              />
            </View>
            <View style={[styles.girdiKutusu, styles.yarim]}>
              <TextInput
                style={styles.girdi}
                placeholder="Soyad"
                value={soyad}
                onChangeText={setSoyad}
              />
            </View>
          </View>

          <View style={styles.girdiKutusu}>
            <Ionicons name="mail-outline" size={18} color={renkler.metinIkincil} />
            <TextInput
              style={styles.girdi}
              placeholder="E-posta"
              autoCapitalize="none"
              keyboardType="email-address"
              value={email}
              onChangeText={setEmail}
            />
          </View>

          <View>
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
            <Text style={styles.ipucu}>En az 8 karakter, en az 1 rakam içermeli</Text>
          </View>

          <Pressable style={styles.buton} onPress={gonder} disabled={yukleniyor}>
            <Text style={styles.butonYazi}>{yukleniyor ? 'Kaydediliyor...' : 'Kayıt ol'}</Text>
          </Pressable>

          <Text style={styles.veyaYazi}>veya</Text>

          <View style={styles.sosyalSatiri}>
            {(['logo-google', 'logo-linkedin', 'logo-apple'] as const).map((ikon) => (
              <Pressable
                key={ikon}
                style={styles.sosyalButon}
                onPress={() => Alert.alert('Yakında', 'Sosyal kayıt henüz eklenmedi.')}
              >
                <Ionicons name={ikon} size={20} color={renkler.lacivert} />
              </Pressable>
            ))}
          </View>

          <View style={styles.girisSatiri}>
            <Text style={styles.altBaslik}>Zaten hesabınız var mı? </Text>
            <Link href="/giris" style={styles.girisLink}>Giriş yap</Link>
          </View>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  kaydirici: { flexGrow: 1, backgroundColor: renkler.beyaz },
  icerik: Platform.OS === 'web' ? { width: '100%', maxWidth: 430, alignSelf: 'center' } : {},
  hero: { width: '100%', height: 320 },
  kart: {
    marginTop: -24,
    backgroundColor: renkler.beyaz,
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    padding: 24,
    gap: 12,
  },
  baslik: { fontSize: 20, fontWeight: '500', textAlign: 'center', color: renkler.lacivert },
  altBaslik: { fontSize: 13, color: renkler.metinIkincil, textAlign: 'center' },
  satir: { flexDirection: 'row', gap: 10 },
  yarim: { flex: 1 },
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
  ipucu: { fontSize: 11, color: renkler.metinIkincil, marginTop: 4, marginLeft: 4 },
  buton: {
    backgroundColor: renkler.lacivert,
    borderRadius: 10,
    height: 48,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 6,
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
  girisSatiri: { flexDirection: 'row', justifyContent: 'center', marginTop: 4 },
  girisLink: { fontSize: 13, color: renkler.mavi, fontWeight: '500' },
});