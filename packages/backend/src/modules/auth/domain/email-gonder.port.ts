export interface EmailGonderPort {
  gonder(alici: string, konu: string, icerikHtml: string): Promise<void>;
}