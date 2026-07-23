export abstract class BaseEntity {
  readonly id: string;
  readonly olusturmaTarihi: Date;

  protected constructor(id: string, olusturmaTarihi: Date) {
    this.id = id;
    this.olusturmaTarihi = olusturmaTarihi;
  }
}
