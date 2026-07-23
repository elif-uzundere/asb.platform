export const FILE_STORAGE_PORT = Symbol('FILE_STORAGE_PORT');

export interface FileStoragePort {
  upload(fileName: string, buffer: Buffer): Promise<string>;
  delete(fileUrl: string): Promise<void>;
}
