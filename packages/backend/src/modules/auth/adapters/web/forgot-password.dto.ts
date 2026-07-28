import { IsEmail } from 'class-validator';
import type { SifremiUnuttumRequest } from '@asb/shared-types';

// Mesajlar Türkçe — bkz. register.dto.ts'teki not.
export class SifremiUnuttumDto implements SifremiUnuttumRequest {
  @IsEmail({}, { message: 'Geçerli bir e-posta adresi girin' })
  email!: string;
}
