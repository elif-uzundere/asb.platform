import { IsEmail, IsString } from 'class-validator';
import type { LoginRequest } from '@asb/shared-types';

export class LoginDto implements LoginRequest {
  @IsEmail()
  email!: string;

  @IsString()
  sifre!: string;
}