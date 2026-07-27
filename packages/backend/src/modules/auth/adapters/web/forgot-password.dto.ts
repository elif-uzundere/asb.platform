import { IsEmail } from 'class-validator';
import type { SifremiUnuttumRequest } from '@asb/shared-types';

export class SifremiUnuttumDto implements SifremiUnuttumRequest {
  @IsEmail()
  email!: string;
}