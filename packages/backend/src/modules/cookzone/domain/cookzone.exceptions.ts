export class CookzoneIsletmeBulunamadiException extends Error {
  constructor() {
    super('Yemek noktası bulunamadı');
  }
}

export class CookzoneMenuOgesiBulunamadiException extends Error {
  constructor() {
    super('Menü öğesi bulunamadı');
  }
}

export class CookzoneSiparisBulunamadiException extends Error {
  constructor() {
    super('Sipariş bulunamadı');
  }
}

/** BR: sepet en az bir kalem içermeli. */
export class BosSepetIleSiparisVerilemezException extends Error {
  constructor() {
    super('Sepetinizde en az bir ürün olmalı');
  }
}

/** BR: teslimat yok, randevulu hazır-olma modeli — geçmişe alım saati verilemez. */
export class GecmisSaateSiparisVerilemezException extends Error {
  constructor() {
    super('Alınma saati şu andan ileride olmalı');
  }
}

/** Bir cookzone_yetkilisi başka işletmenin siparişini görmeye/yönetmeye çalışırsa. */
export class BaskaIsletmeyeAitException extends Error {
  constructor() {
    super('Bu sipariş sizin işletmenize ait değil');
  }
}

/** Sipariş zaten son durumda (`teslim_edildi`), ilerletilemez. */
export class SiparisIlerletilemezException extends Error {
  constructor() {
    super('Bu sipariş artık ilerletilemez');
  }
}

/** Bir cookzone_yetkilisi başka işletmenin menü öğesini düzenlemeye/silmeye çalışırsa. */
export class BaskaIsletmeninMenuOgesiException extends Error {
  constructor() {
    super('Bu menü öğesi sizin işletmenize ait değil');
  }
}
