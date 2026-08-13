export class CookzoneIsletme {
  constructor(
    readonly id: string,
    readonly ad: string,
    readonly bolgeNoktasiId: string,
  ) {}
}

export class CookzoneMenuOgesi {
  constructor(
    readonly id: string,
    readonly isletmeId: string,
    readonly ad: string,
    readonly aciklama: string | null,
    readonly fiyat: number,
    readonly kategori: string,
    readonly aktif: boolean,
  ) {}
}
