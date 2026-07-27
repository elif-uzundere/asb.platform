export interface BannerData {
  id: string;
  gorselUrl: string;
  linkUrl: string | null;
  sira: number;
}

export abstract class BannerRepository {
  abstract aktifBannerlariGetir(): Promise<BannerData[]>;
}