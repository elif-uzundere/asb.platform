/**
 * Harita modülünün tam navigasyon/rota özelliği henüz yazılmadı (Faz 2,
 * bilinçli olarak ertelendi — bkz. docs/isterler.md). Ama Cookzone gibi
 * modüller "bu işletme nerede, adı ne" bilgisine ŞİMDİDEN muhtaç — bu port,
 * tam navigasyon kurulmadan sadece bu dar ihtiyacı karşılıyor. Firma
 * modülündeki `firma-sorgulama.port.ts` ile aynı desen/gerekçe.
 */
export interface BolgeNoktasiSorgulamaPort {
  adiGetir(id: string): Promise<string | null>;
}
