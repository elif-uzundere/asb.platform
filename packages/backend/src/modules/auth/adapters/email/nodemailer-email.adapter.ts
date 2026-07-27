import { Injectable } from '@nestjs/common';
import * as nodemailer from 'nodemailer';
import { EmailGonderPort } from '../../domain';

@Injectable()
export class NodemailerEmailAdapter implements EmailGonderPort {
  private readonly transporter = nodemailer.createTransport({
    host: process.env.EMAIL_HOST,
    port: Number(process.env.EMAIL_PORT ?? 2525),
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  async gonder(alici: string, konu: string, icerikHtml: string): Promise<void> {
    await this.transporter.sendMail({
      from: 'ASB Platform <no-reply@asbplatform.local>',
      to: alici,
      subject: konu,
      html: icerikHtml,
    });
  }
}