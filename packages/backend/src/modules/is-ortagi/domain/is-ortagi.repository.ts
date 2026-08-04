import type { IsOrtagiData } from './is-ortagi.types';

export abstract class IsOrtagiRepository {
  abstract tumunuGetir(): Promise<IsOrtagiData[]>;
}