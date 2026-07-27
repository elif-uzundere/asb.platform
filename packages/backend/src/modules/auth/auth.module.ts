import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AuthService } from './application';
import { KullaniciRepository, SifreHashPort, TokenUreticiPort, EmailGonderPort } from './domain';
import { PrismaKullaniciRepository } from './adapters/persistence/prisma-kullanici.repository';
import { BcryptSifreHashAdapter } from './adapters/security/bcrypt-sifre-hash.adapter';
import { JwtTokenUreticiAdapter } from './adapters/security/jwt-token-uretici.adapter';
import { NodemailerEmailAdapter } from './adapters/email/nodemailer-email.adapter';
import { AuthController } from './adapters/web/auth.controller';
import {
  AUTH_SERVICE,
  KULLANICI_REPOSITORY,
  SIFRE_HASH_PORT,
  TOKEN_URETICI_PORT,
  EMAIL_GONDER_PORT,
} from './auth.tokens';

@Module({
  imports: [
    JwtModule.register({
      secret: process.env.JWT_SECRET ?? 'dev-secret-change-me',
      signOptions: { expiresIn: '7d' },
    }),
  ],
  controllers: [AuthController],
  providers: [
    { provide: KULLANICI_REPOSITORY, useClass: PrismaKullaniciRepository },
    { provide: SIFRE_HASH_PORT, useClass: BcryptSifreHashAdapter },
    { provide: TOKEN_URETICI_PORT, useClass: JwtTokenUreticiAdapter },
    { provide: EMAIL_GONDER_PORT, useClass: NodemailerEmailAdapter },
    {
      provide: AUTH_SERVICE,
      useFactory: (
        repo: KullaniciRepository,
        hash: SifreHashPort,
        token: TokenUreticiPort,
        email: EmailGonderPort,
      ) =>
        new AuthService(
          repo,
          hash,
          token,
          email,
          process.env.SIFIRLAMA_LINK_TABANI ?? 'http://localhost:8081/sifre-sifirla',
        ),
      inject: [KULLANICI_REPOSITORY, SIFRE_HASH_PORT, TOKEN_URETICI_PORT, EMAIL_GONDER_PORT],
    },
  ],
})
export class AuthModule {}