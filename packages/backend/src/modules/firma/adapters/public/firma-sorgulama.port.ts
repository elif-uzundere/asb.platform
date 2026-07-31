export interface FirmaSorgulamaPort {
  isOnayli(firmaId: string): Promise<boolean>;
}
