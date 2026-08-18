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
    readonly gorselUrl: string | null = null,
  ) {}
}

export interface CookzoneMenuOgesiOlusturmaVerisi {
  isletmeId: string;
  ad: string;
  aciklama: string | null;
  fiyat: number;
  kategori: string;
  gorselUrl: string | null;
}

export interface CookzoneMenuOgesiGuncellemeVerisi {
  ad?: string;
  aciklama?: string | null;
  fiyat?: number;
  kategori?: string;
  gorselUrl?: string | null;
  aktif?: boolean;
}
