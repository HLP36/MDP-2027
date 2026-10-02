import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../../prisma/prisma.service';

import * as bcrypt from 'bcrypt';

import { randomBytes } from 'crypto';

import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateMemberDto } from './dto/update-member.dto';

@Injectable()
export class MembersService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  // ======================================================
  // FIND ALL MEMBERS
  // ======================================================

  async findAll() {
    const members =
      await this.prisma.member.findMany({
        orderBy: [
          {
            lastName: 'asc',
          },
          {
            firstName: 'asc',
          },
        ],

        include: {
          organizationalUnit: {
            select: {
              id: true,
              name: true,
              type: true,
            },
          },

          userAccounts: {
            where: {
              accountType: 'MEMBER',
            },
            select: {
              id: true,
              loginId: true,
              email: true,
              status: true,
              accountType: true,
              lastLoginAt: true,
            },
          },

          _count: {
            select: {
              contributions: true,
              contributionObligations: true,
              paymentIntents: true,
            },
          },
        },
      });

    return members.map((member) =>
      this.serializeMember(member),
    );
  }

  // ======================================================
  // FIND ONE MEMBER
  // ======================================================

  async findOne(id: string) {
    const member =
      await this.prisma.member.findUnique({
        where: {
          id,
        },

        include: {
          organizationalUnit: {
            select: {
              id: true,
              name: true,
              type: true,
            },
          },

          userAccounts: {
            where: {
              accountType: 'MEMBER',
            },
            select: {
              id: true,
              loginId: true,
              email: true,
              status: true,
              accountType: true,
              lastLoginAt: true,
              createdAt: true,
            },
          },

          _count: {
            select: {
              contributions: true,
              contributionObligations: true,
              paymentIntents: true,
            },
          },
        },
      });

    if (!member) {
      throw new NotFoundException(
        'Membre introuvable.',
      );
    }

    return this.serializeMember(member);
  }

  // ======================================================
  // CREATE MEMBER
  // ======================================================

  async create(
    createDto: CreateMemberDto,
  ) {
    const memberCode =
      await this.generateMemberCode();

    const temporaryPassword =
      this.generateTemporaryPassword();

    const passwordHash =
      await bcrypt.hash(
        temporaryPassword,
        12,
      );

    const joinedAt =
      this.parseDate(createDto.joinedAt);

    const organizationalUnitId =
      await this.resolveOrganizationalUnit(
        createDto.organizationalUnitId,
      );

    const result =
      await this.prisma.$transaction(
        async (tx) => {
          const member =
            await tx.member.create({
              data: {
                memberCode,

                firstName:
                  createDto.firstName.trim(),

                lastName:
                  createDto.lastName.trim(),

                postName:
                  this.cleanString(
                    createDto.postName,
                  ),

                email:
                  this.cleanEmail(
                    createDto.email,
                  ),

                phone:
                  this.cleanString(
                    createDto.phone,
                  ),

                address:
                  this.cleanString(
                    createDto.address,
                  ),

                field:
                  this.cleanString(
                    createDto.field,
                  ),

                district:
                  this.cleanString(
                    createDto.district,
                  ),

                church:
                  this.cleanString(
                    createDto.church,
                  ),

                joinedAt:
                  joinedAt ?? new Date(),

                status:
                  createDto.status ?? 'ACTIVE',

                organizationalUnitId,
              },
            });

          const user =
            await tx.user.create({
              data: {
                loginId: memberCode,

                email:
                  this.cleanEmail(
                    createDto.email,
                  ),

                passwordHash,

                firstName:
                  createDto.firstName.trim(),

                lastName:
                  createDto.lastName.trim(),

                phone:
                  this.cleanString(
                    createDto.phone,
                  ),

                status: 'ACTIVE',

                accountType: 'MEMBER',

                memberId: member.id,

                organizationalUnitId,
              },
            });

          const memberRole =
            await tx.role.findUnique({
              where: {
                code: 'MEMBRE',
              },
              select: {
                id: true,
              },
            });

          if (!memberRole) {
            throw new ConflictException(
              'Le rôle MEMBRE est introuvable. Exécutez le seed des rôles avant de créer un membre.',
            );
          }

          await tx.userRole.create({
            data: {
              userId: user.id,
              roleId: memberRole.id,
            },
          });

          return {
            member,
            user,
          };
        },
      );

    return {
      member: this.serializeCreatedMember(
        result.member,
        result.user,
      ),

      credentials: {
        loginId: result.user.loginId,
        temporaryPassword,
      },
    };
  }

  // ======================================================
  // UPDATE MEMBER
  // ======================================================

  async update(
    id: string,
    updateDto: UpdateMemberDto,
  ) {
    const existing =
      await this.prisma.member.findUnique({
        where: {
          id,
        },
      });

    if (!existing) {
      throw new NotFoundException(
        'Membre introuvable.',
      );
    }

    const joinedAt =
      this.parseDate(updateDto.joinedAt);

    const organizationalUnitId =
      updateDto.organizationalUnitId !==
      undefined
        ? await this.resolveOrganizationalUnit(
            updateDto.organizationalUnitId,
          )
        : undefined;

    const result =
      await this.prisma.$transaction(
        async (tx) => {
          const member =
            await tx.member.update({
              where: {
                id,
              },

              data: {
                ...(updateDto.firstName !==
                  undefined && {
                  firstName:
                    updateDto.firstName.trim(),
                }),

                ...(updateDto.lastName !==
                  undefined && {
                  lastName:
                    updateDto.lastName.trim(),
                }),

                ...(updateDto.postName !==
                  undefined && {
                  postName:
                    this.cleanString(
                      updateDto.postName,
                    ),
                }),

                ...(updateDto.email !==
                  undefined && {
                  email:
                    this.cleanEmail(
                      updateDto.email,
                    ),
                }),

                ...(updateDto.phone !==
                  undefined && {
                  phone:
                    this.cleanString(
                      updateDto.phone,
                    ),
                }),

                ...(updateDto.address !==
                  undefined && {
                  address:
                    this.cleanString(
                      updateDto.address,
                    ),
                }),

                ...(updateDto.field !==
                  undefined && {
                  field:
                    this.cleanString(
                      updateDto.field,
                    ),
                }),

                ...(updateDto.district !==
                  undefined && {
                  district:
                    this.cleanString(
                      updateDto.district,
                    ),
                }),

                ...(updateDto.church !==
                  undefined && {
                  church:
                    this.cleanString(
                      updateDto.church,
                    ),
                }),

                ...(joinedAt !== undefined && {
                  joinedAt,
                }),

                ...(updateDto.status !==
                  undefined && {
                  status:
                    updateDto.status,
                }),

                ...(organizationalUnitId !==
                  undefined && {
                  organizationalUnitId,
                }),
              },
            });

          await tx.user.updateMany({
            where: {
              memberId: id,
              accountType: 'MEMBER',
            },

            data: {
              ...(updateDto.firstName !==
                undefined && {
                firstName:
                  updateDto.firstName.trim(),
              }),

              ...(updateDto.lastName !==
                undefined && {
                lastName:
                  updateDto.lastName.trim(),
              }),

              ...(updateDto.email !==
                undefined && {
                email:
                  this.cleanEmail(
                    updateDto.email,
                  ),
              }),

              ...(updateDto.phone !==
                undefined && {
                phone:
                  this.cleanString(
                    updateDto.phone,
                  ),
              }),

              ...(updateDto.status !==
                undefined && {
                status:
                  updateDto.status,
              }),

              ...(organizationalUnitId !==
                undefined && {
                organizationalUnitId,
              }),
            },
          });

          return member;
        },
      );

    return this.serializeMember(
      await this.getMemberWithRelations(
        result.id,
      ),
    );
  }

  // ======================================================
  // DELETE / DEACTIVATE MEMBER
  // ======================================================

  async remove(id: string) {
    const member =
      await this.prisma.member.findUnique({
        where: {
          id,
        },
      });

    if (!member) {
      throw new NotFoundException(
        'Membre introuvable.',
      );
    }

    const updated =
      await this.prisma.$transaction(
        async (tx) => {
          const updatedMember =
            await tx.member.update({
              where: {
                id,
              },
              data: {
                status: 'INACTIVE',
              },
            });

          await tx.user.updateMany({
            where: {
              memberId: id,
              accountType: 'MEMBER',
            },
            data: {
              status: 'INACTIVE',
            },
          });

          return updatedMember;
        },
      );

    return {
      success: true,
      message:
        'Le membre a été désactivé.',
      memberId: updated.id,
    };
  }

  // ======================================================
  // HELPERS
  // ======================================================

  private async getMemberWithRelations(
    id: string,
  ) {
    return this.prisma.member.findUniqueOrThrow({
      where: {
        id,
      },

      include: {
        organizationalUnit: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },

        userAccounts: {
          where: {
            accountType: 'MEMBER',
          },

          select: {
            id: true,
            loginId: true,
            email: true,
            status: true,
            accountType: true,
            lastLoginAt: true,
            createdAt: true,
          },
        },

        _count: {
          select: {
            contributions: true,
            contributionObligations: true,
            paymentIntents: true,
          },
        },
      },
    });
  }

  private serializeMember(
    member: any,
  ) {
    const account =
      member.userAccounts?.[0];

    return {
      id: member.id,
      memberCode: member.memberCode,

      firstName: member.firstName,
      lastName: member.lastName,
      postName: member.postName,

      email: member.email,
      phone: member.phone,
      address: member.address,

      field: member.field,
      district: member.district,
      church: member.church,

      joinedAt: member.joinedAt,

      status: member.status,

      organizationalUnit:
        member.organizationalUnit
          ? {
              id:
                member.organizationalUnit.id,
              name:
                member.organizationalUnit.name,
              type:
                member.organizationalUnit.type,
            }
          : null,

      assignment: null,

      credentials: null,

      account: account
        ? {
            id: account.id,
            loginId: account.loginId,
            email: account.email,
            status: account.status,
            accountType:
              account.accountType,
            lastLoginAt:
              account.lastLoginAt,
            createdAt:
              account.createdAt,
          }
        : null,

      statistics: {
        contributions:
          member._count?.contributions ??
          0,

        contributionObligations:
          member._count
            ?.contributionObligations ?? 0,

        paymentIntents:
          member._count
            ?.paymentIntents ?? 0,
      },

      createdAt: member.createdAt,
      updatedAt: member.updatedAt,
    };
  }

  private serializeCreatedMember(
    member: any,
    user: any,
  ) {
    return {
      id: member.id,
      memberCode: member.memberCode,

      firstName: member.firstName,
      lastName: member.lastName,
      postName: member.postName,

      email: member.email,
      phone: member.phone,
      address: member.address,

      field: member.field,
      district: member.district,
      church: member.church,

      joinedAt: member.joinedAt,

      status: member.status,

      organizationalUnit:
        member.organizationalUnitId
          ? {
              id:
                member.organizationalUnitId,
            }
          : null,

      assignment: null,

      credentials: {
        loginId: user.loginId,
      },

      account: {
        id: user.id,
        loginId: user.loginId,
        email: user.email,
        status: user.status,
        accountType:
          user.accountType,
      },

      createdAt: member.createdAt,
      updatedAt: member.updatedAt,
    };
  }

  private async generateMemberCode(): Promise<string> {
    const year =
      new Date().getFullYear();

    const count =
      await this.prisma.member.count();

    let sequence = count + 1;

    while (true) {
      const code =
        `MDP-${year}-${String(sequence).padStart(6, '0')}`;

      const exists =
        await this.prisma.member.findUnique({
          where: {
            memberCode: code,
          },
          select: {
            id: true,
          },
        });

      if (!exists) {
        return code;
      }

      sequence++;
    }
  }

  private generateTemporaryPassword(): string {
    return randomBytes(6)
      .toString('base64url')
      .slice(0, 10);
  }

  private parseDate(
    value?: string,
  ): Date | undefined {
    if (!value) {
      return undefined;
    }

    const date = new Date(value);

    if (Number.isNaN(date.getTime())) {
      throw new ConflictException(
        'La date d’adhésion est invalide.',
      );
    }

    return date;
  }

  private cleanString(
    value?: string,
  ): string | undefined {
    const cleaned =
      value?.trim();

    return cleaned
      ? cleaned
      : undefined;
  }

  private cleanEmail(
    value?: string,
  ): string | undefined {
    const cleaned =
      value?.trim().toLowerCase();

    return cleaned
      ? cleaned
      : undefined;
  }

  private async resolveOrganizationalUnit(
    organizationalUnitId?: string,
  ): Promise<string | undefined> {
    if (organizationalUnitId) {
      const unit =
        await this.prisma.organizationalUnit.findUnique({
          where: {
            id: organizationalUnitId,
          },
          select: {
            id: true,
          },
        });

      if (!unit) {
        throw new NotFoundException(
          'L’unité organisationnelle sélectionnée est introuvable.',
        );
      }

      return unit.id;
    }

    const globalUnit =
      await this.prisma.organizationalUnit.findFirst({
        where: {
          type: 'GLOBAL',
          isActive: true,
        },
        select: {
          id: true,
        },
        orderBy: {
          createdAt: 'asc',
        },
      });

    return globalUnit?.id;
  }
}