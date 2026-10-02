import {
  Controller,
  Get,
} from '@nestjs/common';

import { PrismaService } from '../../prisma/prisma.service';

import { Public } from '../auth/decorators/public.decorator';

// ======================================================
// HEALTH CONTROLLER
// ======================================================

@Controller('health')
export class HealthController {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  // ====================================================
  // HEALTH CHECK
  //
  // GET /api/health
  //
  // Public endpoint.
  // No JWT token required.
  // ====================================================

  @Public()
  @Get()
  async check() {
    try {
      // ================================================
      // DATABASE CONNECTION CHECK
      // ================================================

      await this.prisma.$queryRaw`SELECT 1`;

      return {
        status: 'ok',

        service: 'MDP Backend',

        database: 'connected',

        timestamp:
          new Date().toISOString(),
      };
    } catch {
      return {
        status: 'error',

        service: 'MDP Backend',

        database: 'disconnected',

        timestamp:
          new Date().toISOString(),
      };
    }
  }
}