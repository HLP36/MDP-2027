import {
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';

import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';

import { PrismaService } from '../../prisma/prisma.service';

import * as bcrypt from 'bcrypt';

import { createHash, randomBytes } from 'crypto';

import type { StringValue } from 'ms';

import { LoginDto } from './dto/login.dto';
import { JwtPayload } from './types/auth.types';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  // =====================================================
  // LOGIN
  // =====================================================

  async login(
    dto: LoginDto,
    ipAddress?: string,
    userAgent?: string,
  ) {
    const identifier = dto.identifier.trim();

    const user = await this.prisma.user.findFirst({
      where: {
        OR: [
          {
            email: identifier,
          },
          {
            loginId: identifier,
          },
        ],
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

    if (!user) {
      throw new UnauthorizedException(
        'Identifiants incorrects.',
      );
    }

    if (user.status !== 'ACTIVE') {
      throw new UnauthorizedException(
        'Ce compte n’est pas actif.',
      );
    }

    const passwordValid = await bcrypt.compare(
      dto.password,
      user.passwordHash,
    );

    if (!passwordValid) {
      throw new UnauthorizedException(
        'Identifiants incorrects.',
      );
    }

    const roles = user.roles.map(
      (item) => item.role.code,
    );

    const permissions = [
      ...new Set(
        user.roles.flatMap((userRole) =>
          userRole.role.permissions.map(
            (rolePermission) =>
              rolePermission.permission.code,
          ),
        ),
      ),
    ];

    /*
     * On utilise une valeur temporaire unique pour respecter
     * la contrainte @unique de refreshTokenHash.
     *
     * Le vrai hash du refresh token est enregistré juste
     * après la génération du token.
     */
    const temporaryRefreshTokenHash =
      createHash('sha256')
        .update(randomBytes(32))
        .digest('hex');

    const session = await this.prisma.userSession.create({
      data: {
        userId: user.id,
        refreshTokenHash: temporaryRefreshTokenHash,
        expiresAt: new Date(
          Date.now() +
            this.getRefreshTokenLifetimeMs(),
        ),
      },
    });

    const payload: JwtPayload = {
      sub: user.id,
      sid: session.id,
      accountType: user.accountType,
      memberId: user.memberId,
      roles,
    };

    const accessToken =
      await this.jwtService.signAsync(payload, {
        secret: this.getAccessSecret(),
        expiresIn: this.getAccessTokenLifetime(),
      });

    const refreshToken =
      await this.jwtService.signAsync(payload, {
        secret: this.getRefreshSecret(),
        expiresIn: this.getRefreshTokenLifetime(),
      });

    await this.prisma.userSession.update({
      where: {
        id: session.id,
      },
      data: {
        refreshTokenHash:
          this.hashToken(refreshToken),
      },
    });

    await this.prisma.user.update({
      where: {
        id: user.id,
      },
      data: {
        lastLoginAt: new Date(),
      },
    });

    await this.prisma.auditLog.create({
      data: {
        userId: user.id,
        action: 'LOGIN',
        entity: 'User',
        entityId: user.id,
        ipAddress,
        userAgent,
      },
    });

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        loginId: user.loginId,
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone,
        status: user.status,
        accountType: user.accountType,
        memberId: user.memberId,
        roles,
        permissions,
      },
    };
  }

  // =====================================================
  // CURRENT USER
  // =====================================================

  async me(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: {
        id: userId,
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

    if (!user || user.status !== 'ACTIVE') {
      throw new UnauthorizedException(
        'Session utilisateur invalide.',
      );
    }

    const roles = user.roles.map(
      (item) => item.role.code,
    );

    const permissions = [
      ...new Set(
        user.roles.flatMap((userRole) =>
          userRole.role.permissions.map(
            (rolePermission) =>
              rolePermission.permission.code,
          ),
        ),
      ),
    ];

    return {
      id: user.id,
      email: user.email,
      loginId: user.loginId,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      status: user.status,
      accountType: user.accountType,
      memberId: user.memberId,
      roles,
      permissions,
    };
  }

  // =====================================================
  // REFRESH
  // =====================================================

  async refresh(refreshToken: string) {
    let payload: JwtPayload;

    try {
      payload =
        await this.jwtService.verifyAsync<JwtPayload>(
          refreshToken,
          {
            secret: this.getRefreshSecret(),
          },
        );
    } catch {
      throw new UnauthorizedException(
        'Refresh token invalide ou expiré.',
      );
    }

    const session =
      await this.prisma.userSession.findUnique({
        where: {
          id: payload.sid,
        },
      });

    if (!session) {
      throw new UnauthorizedException(
        'Session introuvable.',
      );
    }

    if (session.revokedAt) {
      throw new UnauthorizedException(
        'Session révoquée.',
      );
    }

    if (session.expiresAt <= new Date()) {
      throw new UnauthorizedException(
        'Session expirée.',
      );
    }

    const validHash = this.verifyTokenHash(
      refreshToken,
      session.refreshTokenHash,
    );

    if (!validHash) {
      throw new UnauthorizedException(
        'Refresh token invalide.',
      );
    }

    const user = await this.me(payload.sub);

    const newPayload: JwtPayload = {
      sub: user.id,
      sid: session.id,
      accountType: user.accountType,
      memberId: user.memberId,
      roles: user.roles,
    };

    const accessToken =
      await this.jwtService.signAsync(newPayload, {
        secret: this.getAccessSecret(),
        expiresIn: this.getAccessTokenLifetime(),
      });

    const newRefreshToken =
      await this.jwtService.signAsync(newPayload, {
        secret: this.getRefreshSecret(),
        expiresIn: this.getRefreshTokenLifetime(),
      });

    await this.prisma.userSession.update({
      where: {
        id: session.id,
      },
      data: {
        refreshTokenHash:
          this.hashToken(newRefreshToken),
        lastUsedAt: new Date(),
      },
    });

    return {
      accessToken,
      refreshToken: newRefreshToken,
      user,
    };
  }

  // =====================================================
  // LOGOUT
  // =====================================================

  async logout(
    userId: string,
    sessionId: string,
    ipAddress?: string,
    userAgent?: string,
  ) {
    await this.prisma.userSession.updateMany({
      where: {
        id: sessionId,
        userId,
        revokedAt: null,
      },
      data: {
        revokedAt: new Date(),
      },
    });

    await this.prisma.auditLog.create({
      data: {
        userId,
        action: 'LOGOUT',
        entity: 'UserSession',
        entityId: sessionId,
        ipAddress,
        userAgent,
      },
    });

    return {
      success: true,
    };
  }

  // =====================================================
  // TOKEN HELPERS
  // =====================================================

  private hashToken(token: string): string {
    return createHash('sha256')
      .update(token)
      .digest('hex');
  }

  private verifyTokenHash(
    token: string,
    storedHash: string,
  ): boolean {
    return this.hashToken(token) === storedHash;
  }

  private getAccessSecret(): string {
    return (
      this.configService.get<string>(
        'JWT_ACCESS_SECRET',
      ) ?? 'mdp-development-access-secret'
    );
  }

  private getRefreshSecret(): string {
    return (
      this.configService.get<string>(
        'JWT_REFRESH_SECRET',
      ) ?? 'mdp-development-refresh-secret'
    );
  }

  private getAccessTokenLifetime(): StringValue {
    return (
      this.configService.get<string>(
        'JWT_ACCESS_EXPIRES_IN',
      ) ?? '15m'
    ) as StringValue;
  }

  private getRefreshTokenLifetime(): StringValue {
    return (
      this.configService.get<string>(
        'JWT_REFRESH_EXPIRES_IN',
      ) ?? '30d'
    ) as StringValue;
  }

  private getRefreshTokenLifetimeMs(): number {
    return 30 * 24 * 60 * 60 * 1000;
  }
}