import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';

import { Reflector } from '@nestjs/core';

import { PrismaService } from '../../../prisma/prisma.service';

import {
  PERMISSIONS_KEY,
} from '../decorators/permissions.decorator';

@Injectable()
export class PermissionsGuard
  implements CanActivate
{
  constructor(
    private readonly reflector: Reflector,

    private readonly prisma: PrismaService,
  ) {}

  async canActivate(
    context: ExecutionContext,
  ): Promise<boolean> {
    const requiredPermissions =
      this.reflector.getAllAndOverride<string[]>(
        PERMISSIONS_KEY,
        [
          context.getHandler(),
          context.getClass(),
        ],
      );

    // ==========================================
    // NO PERMISSION REQUIRED
    // ==========================================

    if (
      !requiredPermissions ||
      requiredPermissions.length === 0
    ) {
      return true;
    }

    const request = context
      .switchToHttp()
      .getRequest();

    const user = request.user;

    if (!user?.id) {
      throw new ForbiddenException(
        'Utilisateur non authentifié.',
      );
    }

    // ==========================================
    // GET USER PERMISSIONS
    // ==========================================

    const userWithPermissions =
      await this.prisma.user.findUnique({
        where: {
          id: user.id,
        },

        include: {
          roles: {
            include: {
              role: {
                include: {
                  permissions: {
                    include: {
                      permission: true,
                    },
                  },
                },
              },
            },
          },
        },
      });

    if (!userWithPermissions) {
      throw new ForbiddenException(
        'Utilisateur introuvable.',
      );
    }

    // ==========================================
    // EXTRACT PERMISSIONS
    // ==========================================

    const userPermissions =
      userWithPermissions.roles.flatMap(
        (userRole) =>
          userRole.role.permissions.map(
            (rolePermission) =>
              rolePermission.permission.code,
          ),
      );

    // ==========================================
    // REMOVE DUPLICATES
    // ==========================================

    const uniquePermissions = [
      ...new Set(userPermissions),
    ];

    // ==========================================
    // CHECK REQUIRED PERMISSIONS
    // ==========================================

    const hasPermission =
      requiredPermissions.every(
        (permission) =>
          uniquePermissions.includes(
            permission,
          ),
      );

    if (!hasPermission) {
      throw new ForbiddenException(
        'Vous ne disposez pas des permissions nécessaires.',
      );
    }

    return true;
  }
}