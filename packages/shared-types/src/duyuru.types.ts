export interface DuyuruResponse {
  id: string;
  baslik: string;
  icerik: string;
  kategori: string | null;
  yayinTarihi: string;
}