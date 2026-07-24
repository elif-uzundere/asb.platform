import type { LoginRequest, LoginResponse, RegisterRequest } from '@asb/shared-types';
import { apiClient } from '../../core/api/client';

interface ApiZarf<T> {
  success: boolean;
  data?: T;
  error?: { code: string; message: string };
}

export async function girisYapIstegi(dto: LoginRequest): Promise<LoginResponse> {
  const yanit = await apiClient.post<ApiZarf<LoginResponse>>('/auth/login', dto);
  return yanit.data.data!;
}

export async function kayitOlIstegi(dto: RegisterRequest): Promise<LoginResponse> {
  const yanit = await apiClient.post<ApiZarf<LoginResponse>>('/auth/register', dto);
  return yanit.data.data!;
}