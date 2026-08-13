export interface FirmaSorgulamaPort {
  isOnayli(firmaId: string): Promise<boolean>;

  /** İş ilanı listesinde/detayında firma adını göstermek için — `is-ilanlari` kullanıyor. */
  adiGetir(firmaId: string): Promise<string | null>;
}
