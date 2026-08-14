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
