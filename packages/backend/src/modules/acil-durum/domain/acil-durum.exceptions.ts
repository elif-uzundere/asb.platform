/**
 * BR-5: Konum toplanmadığı için (harita modülü kapsam dışı) bildirimin
 * anlamlı olabilmesi için açıklama zorunlu — ikisinden en az biri (konum ya
 * da açıklama) dolu olmalı kuralının, konum hiç yokken sadeleşmiş hali.
 */
export class AciklamaZorunluException extends Error {
  constructor() {
    super('Bildirim için açıklama girmelisiniz');
  }
}

export class BildirimBulunamadiException extends Error {
  constructor() {
    super('Bildirim bulunamadı');
  }
}

/** Bir ekip üyesi, kendi türüne düşmeyen bir bildirimin durumunu değiştirmeye çalışırsa. */
export class BaskaEkibeAitException extends Error {
  constructor() {
    super('Bu bildirim sizin ekibinize ait değil');
  }
}
