import { StyleSheet, Text, View } from 'react-native';
import { Banner } from '../../src/features/ana-sayfa/components/banner';
export default function AnaSayfaScreen() {
  return (
   <View style={styles.container}>
  <Banner />


  <Text>
    Ana Sayfa - banner, duyuru ve iş ortakları burada listelenecek.
  </Text>
</View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
    paddingHorizontal: 16,
    paddingTop: 10,
}

});
