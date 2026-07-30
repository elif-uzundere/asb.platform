export interface DuyuruData {
  id: string;
  baslik: string;
  icerik: string;
 kategori: string | null;
  yayinTarihi: Date;
}

export abstract class DuyuruRepository {
  abstract tumDuyurulariGetir(): Promise<DuyuruData[]>;

  abstract duyuruGetir(
    id: string,
  ): Promise<DuyuruData | null>;
}