import { StyleSheet, Text, View } from 'react-native';

export default function FirmalarScreen() {
  return (
    <View style={styles.container}>
      <Text>Firmalar</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
});
