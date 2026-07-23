import { StyleSheet, Text, View } from 'react-native';

export default function AdminPanelScreen() {
  return (
    <View style={styles.container}>
      <Text>Admin Paneli</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, alignItems: 'center', justifyContent: 'center' },
});
