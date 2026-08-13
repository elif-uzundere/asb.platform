export class IsIlaniBulunamadiException extends Error {
  constructor() {
    super('İş ilanı bulunamadı');
  }
}

/** BR-2: onay_durumu != onaylandi olan firmalar iş ilanı yayınlayamaz. */
export class FirmaOnayliDegilException extends Error {
  constructor() {
    super('Sadece onaylı firmalar iş ilanı yayınlayabilir');
  }
}

/** Bir firma yetkilisi başka firmanın ilanını kapatmaya/başvurularını görmeye çalışırsa. */
export class BaskaFirmayaAitException extends Error {
  constructor() {
    super('Bu ilan sizin firmanıza ait değil');
  }
}

export class ZatenBasvurulduException extends Error {
  constructor() {
    super('Bu ilana zaten başvurdunuz');
  }
}

export class IlanKapaliException extends Error {
  constructor() {
    super('Bu ilan artık başvuruya kapalı');
  }
}

export class BasvuruBulunamadiException extends Error {
  constructor() {
    super('Başvuru bulunamadı');
  }
}
