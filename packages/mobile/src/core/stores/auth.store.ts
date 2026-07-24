import { create } from 'zustand';
import { createJSONStorage, persist, type StateStorage } from 'zustand/middleware';
import { Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';
import type { KullaniciOzet, LoginRequest, RegisterRequest } from '@asb/shared-types';
import { girisYapIstegi, kayitOlIstegi } from '../../features/auth/auth.api';
import { apiClient } from '../api/client';

const guvenliDepo: StateStorage = {
  getItem: async (ad) => {
    if (Platform.OS === 'web') return localStorage.getItem(ad);
    return SecureStore.getItemAsync(ad);
  },
  setItem: async (ad, deger) => {
    if (Platform.OS === 'web') { localStorage.setItem(ad, deger); return; }
    await SecureStore.setItemAsync(ad, deger);
  },
  removeItem: async (ad) => {
    if (Platform.OS === 'web') { localStorage.removeItem(ad); return; }
    await SecureStore.deleteItemAsync(ad);
  },
};

interface AuthState {
  kullanici: KullaniciOzet | null;
  accessToken: string | null;
  girisYap: (dto: LoginRequest) => Promise<void>;
  kayitOl: (dto: RegisterRequest) => Promise<void>;
  cikisYap: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      kullanici: null,
      accessToken: null,

      girisYap: async (dto) => {
        const sonuc = await girisYapIstegi(dto);
        set({ kullanici: sonuc.kullanici, accessToken: sonuc.accessToken });
      },

      kayitOl: async (dto) => {
        const sonuc = await kayitOlIstegi(dto);
        set({ kullanici: sonuc.kullanici, accessToken: sonuc.accessToken });
      },

      cikisYap: () => set({ kullanici: null, accessToken: null }),
    }),
    {
      name: 'asb-auth',
      storage: createJSONStorage(() => guvenliDepo),
    },
  ),
);

apiClient.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});