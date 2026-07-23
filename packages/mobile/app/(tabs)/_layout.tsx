import { Tabs } from 'expo-router';

export default function TabsLayout() {
  return (
    <Tabs>
      <Tabs.Screen name="index" options={{ title: 'Ana Sayfa' }} />
      <Tabs.Screen name="firmalar" options={{ title: 'Firmalar' }} />
      <Tabs.Screen name="harita" options={{ title: 'Harita' }} />
      <Tabs.Screen name="duyurular" options={{ title: 'Duyurular' }} />
      <Tabs.Screen name="profil" options={{ title: 'Profil' }} />
    </Tabs>
  );
}
