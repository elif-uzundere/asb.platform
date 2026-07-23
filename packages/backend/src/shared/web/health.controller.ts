import { Controller, Get } from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { ApiResponseDto } from './api-response.dto';

@ApiTags('health')
@Controller('health')
export class HealthController {
  @Get()
  check() {
    return ApiResponseDto.ok({ status: 'ok', timestamp: new Date().toISOString() });
  }
}
