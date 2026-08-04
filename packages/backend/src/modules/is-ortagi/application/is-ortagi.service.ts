import { Injectable } from '@nestjs/common';

import {
  IsOrtagiData,
  IsOrtagiRepository,
} from '../domain';

@Injectable()
export class IsOrtagiService {
  constructor(
    private readonly isOrtagiRepository: IsOrtagiRepository,
  ) {}

  async tumunuGetir(): Promise<IsOrtagiData[]> {
    return this.isOrtagiRepository.tumunuGetir();
  }
}

