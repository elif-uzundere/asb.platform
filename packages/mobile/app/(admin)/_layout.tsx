import { Stack } from 'expo-router';

// Rol kontrolü (authStore.rol === 'admin') Adım 7'de (FAZ 1) bağlanacak.
export default function AdminLayout() {
  return <Stack screenOptions={{ headerShown: false }} />;
}
