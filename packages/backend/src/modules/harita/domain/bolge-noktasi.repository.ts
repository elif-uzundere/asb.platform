export interface BolgeNoktasiRepository {
  adiGetir(id: string): Promise<string | null>;
}
