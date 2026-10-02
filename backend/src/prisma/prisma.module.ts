import {
  Global,
  Module,
} from '@nestjs/common';

import { PrismaService } from './prisma.service';

// ======================================================
// PRISMA MODULE
// ======================================================

@Global()
@Module({
  providers: [
    PrismaService,
  ],

  exports: [
    PrismaService,
  ],
})
export class PrismaModule {}