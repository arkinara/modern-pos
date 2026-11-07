import { Controller, Get, ServiceUnavailableException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface HealthResponse {
  status: 'ok';
  service: 'modern-pos-api';
  version: string;
  database: 'up';
}

@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  async check(): Promise<HealthResponse> {
    const databaseUp = await this.prisma.isHealthy();

    if (!databaseUp) {
      throw new ServiceUnavailableException('Database is not reachable');
    }

    return {
      status: 'ok',
      service: 'modern-pos-api',
      version: '0.1.0',
      database: 'up',
    };
  }
}
