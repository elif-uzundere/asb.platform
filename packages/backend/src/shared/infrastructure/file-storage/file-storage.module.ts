import { Global, Module } from '@nestjs/common';
import { FILE_STORAGE_PORT } from './file-storage.port';
import { LocalFileStorageAdapter } from './local-file-storage.adapter';

@Global()
@Module({
  providers: [
    {
      provide: FILE_STORAGE_PORT,
      useFactory: () => new LocalFileStorageAdapter(),
    },
  ],
  exports: [FILE_STORAGE_PORT],
})
export class FileStorageModule {}
