export interface DuyuruData {
  id: string;
  baslik: string;
  icerik: string;
  kategori: string | null;
  yayinTarihi: Date;
}

export interface DuyuruOlusturmaVerisi {
  baslik: string;
  icerik: string;
  kategori?: string;
  yayinTarihi?: Date;
  olusturanKullaniciId: string;
}

export abstract class DuyuruRepository {
  abstract tumDuyurulariGetir(): Promise<DuyuruData[]>;

  abstract duyuruGetir(id: string): Promise<DuyuruData | null>;

  abstract duyuruOlustur(veri: DuyuruOlusturmaVerisi): Promise<DuyuruData>;
}
