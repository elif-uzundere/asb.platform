export class FirmaBulunamadiException extends Error {
  constructor() {
    super('Firma bulunamadı');
  }
}

/**
 * Zaten onaylı bir firmayı tekrar onaylama denemesi. Sessizce başarılı
 * saymak yerine hata veriyoruz: admin yanlış satıra bastığını fark etsin.
 */
export class FirmaZatenOnayliException extends Error {
  constructor() {
    super('Bu firma zaten onaylı');
  }
}
