import { StyleSheet, Text, View } from 'react-native';

export default function HaritaScreen() {
  return (
    <View style={styles.container}>
      <Text>Bölge İçi Navigasyon</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
});
