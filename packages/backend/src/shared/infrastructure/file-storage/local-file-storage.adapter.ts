import { randomUUID } from 'crypto';
import { mkdir, unlink, writeFile } from 'fs/promises';
import { extname, join } from 'path';
import { FileStoragePort } from './file-storage.port';

const UPLOADS_DIR = join(process.cwd(), 'uploads');

export class LocalFileStorageAdapter implements FileStoragePort {
  async upload(fileName: string, buffer: Buffer): Promise<string> {
    await mkdir(UPLOADS_DIR, { recursive: true });
    const storedName = `${randomUUID()}${extname(fileName)}`;
    await writeFile(join(UPLOADS_DIR, storedName), buffer);
    return `/uploads/${storedName}`;
  }

  async delete(fileUrl: string): Promise<void> {
    const storedName = fileUrl.replace('/uploads/', '');
    await unlink(join(UPLOADS_DIR, storedName));
  }
}
