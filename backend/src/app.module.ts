import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { ConfigModule } from '@nestjs/config';

// ======================================================
// CORE
// ======================================================

import { PrismaModule } from './prisma/prisma.module';

// ======================================================
// SYSTEM MODULES
// ======================================================

import { HealthModule } from './modules/health/health.module';
import { AuthModule } from './modules/auth/auth.module';

// ======================================================
// AUTH GUARDS
// ======================================================

import { JwtAuthGuard } from './modules/auth/guards/jwt-auth.guard';
import { RolesGuard } from './modules/auth/guards/roles.guard';
import { PermissionsGuard } from './modules/auth/guards/permissions.guard';

// ======================================================
// IDENTITY & ACCESS MANAGEMENT
// ======================================================

import { UsersModule } from './modules/users/users.module';
import { RolesModule } from './modules/roles/roles.module';
import { PermissionsModule } from './modules/permissions/permissions.module';

// ======================================================
// ORGANIZATION
// ======================================================

import { OrganizationModule } from './modules/organization/organization.module';

// ======================================================
// MDP CORE MODULES
// ======================================================

import { MembersModule } from './modules/members/members.module';
import { ActivitiesModule } from './modules/activities/activities.module';
import { ReportsModule } from './modules/reports/reports.module';
import { ContributionsModule } from './modules/contributions/contributions.module';
import { ProjectsModule } from './modules/projects/projects.module';
import { SponsorsModule } from './modules/sponsors/sponsors.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { DashboardModule } from './modules/dashboard/dashboard.module';
import { AuditModule } from './modules/audit/audit.module';

// ======================================================
// APPLICATION MODULE
// ======================================================

@Module({
  imports: [
    // ==================================================
    // CONFIGURATION
    // ==================================================

    ConfigModule.forRoot({
      isGlobal: true,
    }),

    // ==================================================
    // DATABASE
    // ==================================================

    PrismaModule,

    // ==================================================
    // SYSTEM
    // ==================================================

    HealthModule,

    AuthModule,

    // ==================================================
    // IDENTITY & ACCESS MANAGEMENT
    // ==================================================

    UsersModule,

    RolesModule,

    PermissionsModule,

    // ==================================================
    // ORGANIZATION
    // ==================================================

    OrganizationModule,

    // ==================================================
    // MDP CORE MODULES
    // ==================================================

    MembersModule,

    ActivitiesModule,

    ReportsModule,

    ContributionsModule,

    ProjectsModule,

    SponsorsModule,

    NotificationsModule,

    DashboardModule,

    AuditModule,
  ],

  // ====================================================
  // GLOBAL SECURITY
  // ====================================================

  providers: [
    // ==================================================
    // JWT AUTHENTICATION
    //
    // All routes are protected by default.
    //
    // Use @Public() for routes that must remain public.
    // ==================================================

    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },

    // ==================================================
    // ROLE AUTHORIZATION
    //
    // Use:
    //
    // @Roles('SUPER_ADMIN')
    //
    // on protected routes.
    // ==================================================

    {
      provide: APP_GUARD,
      useClass: RolesGuard,
    },

    // ==================================================
    // PERMISSION AUTHORIZATION
    //
    // Use:
    //
    // @Permissions('organization.read')
    //
    // on protected routes.
    // ==================================================

    {
      provide: APP_GUARD,
      useClass: PermissionsGuard,
    },
  ],
})
export class AppModule {}