import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../../prisma/prisma.service';
import { OrganizationalUnitType } from '../../generated/prisma';

import { CreateOrganizationalUnitDto } from './dto/create-organizational-unit.dto';
import { UpdateOrganizationalUnitDto } from './dto/update-organizational-unit.dto';
import { QueryOrganizationalUnitDto } from './dto/query-organizational-unit.dto';

// ======================================================
// ORGANIZATION SERVICE
// ======================================================

@Injectable()
export class OrganizationService {
  constructor(
    private readonly prisma: PrismaService,
  ) {}

  // ======================================================
  // ORGANIZATION OVERVIEW
  // ======================================================

  async getOverview() {
    const [
      unitsCount,
      members,
      leaders,
      activeUnitsWithoutLeader,
    ] = await Promise.all([
      // --------------------------------------------------
      // TOTAL ORGANIZATIONAL UNITS
      // --------------------------------------------------
      this.prisma.organizationalUnit.count(),

      // --------------------------------------------------
      // UNIQUE MEMBERS
      //
      // Important:
      // A member can have two User accounts:
      // 1. MEMBER account
      // 2. RESPONSIBILITY account
      //
      // We therefore count distinct memberId values
      // instead of counting User records directly.
      // --------------------------------------------------
      this.prisma.user.findMany({
        where: {
          organizationalUnitId: {
            not: null,
          },
          memberId: {
            not: null,
          },
        },
        select: {
          memberId: true,
        },
        distinct: ['memberId'],
      }),

      // --------------------------------------------------
      // UNIQUE ORGANIZATIONAL LEADERS
      // --------------------------------------------------
      this.prisma.organizationalUnit.findMany({
        where: {
          leaderId: {
            not: null,
          },
        },
        select: {
          leaderId: true,
        },
        distinct: ['leaderId'],
      }),

      // --------------------------------------------------
      // ACTIVE UNITS WITHOUT LEADER
      //
      // This is currently our operational alert metric.
      // --------------------------------------------------
      this.prisma.organizationalUnit.count({
        where: {
          isActive: true,
          leaderId: null,
        },
      }),
    ]);

    return {
      unitsCount,
      membersCount: members.length,
      leadersCount: leaders.length,
      alertsCount: activeUnitsWithoutLeader,
    };
  }

  // ======================================================
  // CREATE ORGANIZATIONAL UNIT
  // ======================================================

  async create(
    createDto: CreateOrganizationalUnitDto,
  ) {
    const {
      parentId,
      leaderId,
      ...data
    } = createDto;

    // ====================================================
    // CHECK PARENT
    // ====================================================

    if (parentId) {
      const parent =
        await this.prisma.organizationalUnit.findUnique({
          where: {
            id: parentId,
          },
        });

      if (!parent) {
        throw new NotFoundException(
          'L’unité organisationnelle parente est introuvable.',
        );
      }
    }

    // ====================================================
    // CHECK LEADER
    // ====================================================

    if (leaderId) {
      const leader =
        await this.prisma.user.findUnique({
          where: {
            id: leaderId,
          },
        });

      if (!leader) {
        throw new NotFoundException(
          'Le responsable sélectionné est introuvable.',
        );
      }
    }

    // ====================================================
    // CREATE UNIT
    // ====================================================

    return this.prisma.organizationalUnit.create({
      data: {
        ...data,
        parentId,
        leaderId,
        isActive:
          createDto.isActive ?? true,
      },

      include: {
        parent: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },

        leader: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    });
  }

  // ======================================================
  // FIND ALL
  // ======================================================

  async findAll(
    query: QueryOrganizationalUnitDto,
  ) {
    const {
      type,
      parentId,
      isActive,
    } = query;

    return this.prisma.organizationalUnit.findMany({
      where: {
        ...(type && {
          type,
        }),

        ...(parentId && {
          parentId,
        }),

        ...(isActive !== undefined && {
          isActive:
            isActive === 'true',
        }),
      },

      include: {
        parent: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },

        leader: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },

        _count: {
          select: {
            children: true,
            users: true,
          },
        },
      },

      orderBy: [
        {
          type: 'asc',
        },

        {
          name: 'asc',
        },
      ],
    });
  }

  // ======================================================
  // FIND ONE
  // ======================================================

  async findOne(
    id: string,
  ) {
    const unit =
      await this.prisma.organizationalUnit.findUnique({
        where: {
          id,
        },

        include: {
          parent: {
            select: {
              id: true,
              name: true,
              type: true,
            },
          },

          children: {
            select: {
              id: true,
              name: true,
              type: true,
              isActive: true,
            },

            orderBy: {
              name: 'asc',
            },
          },

          leader: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
              status: true,
            },
          },

          _count: {
            select: {
              children: true,
              users: true,
            },
          },
        },
      });

    if (!unit) {
      throw new NotFoundException(
        'L’unité organisationnelle est introuvable.',
      );
    }

    return unit;
  }

  // ======================================================
  // GET ORGANIZATIONAL TREE
  // ======================================================

  async getTree() {
    const units =
      await this.prisma.organizationalUnit.findMany({
        include: {
          leader: {
            select: {
              id: true,
              firstName: true,
              lastName: true,
              email: true,
            },
          },
        },

        orderBy: {
          name: 'asc',
        },
      });

    return this.buildTree(units);
  }

  // ======================================================
  // BUILD TREE
  // ======================================================

  private buildTree(
    units: Array<{
      id: string;
      name: string;
      type: OrganizationalUnitType;
      description: string | null;
      parentId: string | null;
      leaderId: string | null;
      isActive: boolean;
      createdAt: Date;
      updatedAt: Date;

      leader: {
        id: string;
        firstName: string;
        lastName: string;
        email: string | null;
      } | null;
    }>,
  ) {
    type TreeNode =
      (typeof units)[number] & {
        children: TreeNode[];
      };

    const map =
      new Map<string, TreeNode>();

    const roots: TreeNode[] = [];

    // ====================================================
    // CREATE MAP
    // ====================================================

    for (const unit of units) {
      map.set(unit.id, {
        ...unit,
        children: [],
      });
    }

    // ====================================================
    // BUILD HIERARCHY
    // ====================================================

    for (const unit of units) {
      const node =
        map.get(unit.id);

      if (!node) {
        continue;
      }

      if (
        unit.parentId &&
        map.has(unit.parentId)
      ) {
        const parent =
          map.get(unit.parentId);

        if (parent) {
          parent.children.push(node);
        }
      } else {
        roots.push(node);
      }
    }

    return roots;
  }

  // ======================================================
  // UPDATE ORGANIZATIONAL UNIT
  // ======================================================

  async update(
    id: string,
    updateDto: UpdateOrganizationalUnitDto,
  ) {
    // ====================================================
    // CHECK UNIT
    // ====================================================

    const unit =
      await this.prisma.organizationalUnit.findUnique({
        where: {
          id,
        },
      });

    if (!unit) {
      throw new NotFoundException(
        'L’unité organisationnelle est introuvable.',
      );
    }

    const {
      parentId,
      leaderId,
      ...data
    } = updateDto;

    // ====================================================
    // CHECK PARENT
    // ====================================================

    if (
      parentId !== undefined &&
      parentId !== null
    ) {
      if (parentId === id) {
        throw new BadRequestException(
          'Une unité ne peut pas être son propre parent.',
        );
      }

      const parent =
        await this.prisma.organizationalUnit.findUnique({
          where: {
            id: parentId,
          },
        });

      if (!parent) {
        throw new NotFoundException(
          'L’unité organisationnelle parente est introuvable.',
        );
      }

      // ==================================================
      // PREVENT CIRCULAR HIERARCHY
      // ==================================================

      await this.validateParentHierarchy(
        id,
        parentId,
      );
    }

    // ====================================================
    // CHECK LEADER
    // ====================================================

    if (
      leaderId !== undefined &&
      leaderId !== null
    ) {
      const leader =
        await this.prisma.user.findUnique({
          where: {
            id: leaderId,
          },
        });

      if (!leader) {
        throw new NotFoundException(
          'Le responsable sélectionné est introuvable.',
        );
      }
    }

    // ====================================================
    // UPDATE
    // ====================================================

    return this.prisma.organizationalUnit.update({
      where: {
        id,
      },

      data: {
        ...data,

        ...(parentId !== undefined && {
          parentId,
        }),

        ...(leaderId !== undefined && {
          leaderId,
        }),
      },

      include: {
        parent: {
          select: {
            id: true,
            name: true,
            type: true,
          },
        },

        leader: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            email: true,
          },
        },
      },
    });
  }

  // ======================================================
  // VALIDATE PARENT HIERARCHY
  // ======================================================

  private async validateParentHierarchy(
    unitId: string,
    newParentId: string,
  ) {
    let currentParentId:
      | string
      | null = newParentId;

    while (currentParentId) {
      if (currentParentId === unitId) {
        throw new BadRequestException(
          'Cette opération créerait une boucle dans la hiérarchie organisationnelle.',
        );
      }

      const parent =
        await this.prisma.organizationalUnit.findUnique({
          where: {
            id: currentParentId,
          },

          select: {
            parentId: true,
          },
        });

      if (!parent) {
        break;
      }

      currentParentId =
        parent.parentId;
    }
  }

  // ======================================================
  // DELETE ORGANIZATIONAL UNIT
  // ======================================================

  async remove(
    id: string,
  ) {
    const unit =
      await this.prisma.organizationalUnit.findUnique({
        where: {
          id,
        },

        include: {
          _count: {
            select: {
              children: true,
              users: true,
            },
          },
        },
      });

    if (!unit) {
      throw new NotFoundException(
        'L’unité organisationnelle est introuvable.',
      );
    }

    // ====================================================
    // PROTECT GLOBAL UNIT
    // ====================================================

    if (unit.type === OrganizationalUnitType.GLOBAL) {
      throw new BadRequestException(
        'L’unité organisationnelle globale ne peut pas être supprimée.',
      );
    }

    // ====================================================
    // CHECK DEPENDENCIES
    // ====================================================

    const {
      children,
      users,
    } = unit._count;

    if (children > 0) {
      throw new BadRequestException(
        'Impossible de supprimer cette unité car elle possède des sous-unités.',
      );
    }

    if (users > 0) {
      throw new BadRequestException(
        'Impossible de supprimer cette unité car elle contient des utilisateurs.',
      );
    }

    // ====================================================
    // DELETE
    // ====================================================

    await this.prisma.organizationalUnit.delete({
      where: {
        id,
      },
    });

    return {
      message:
        'L’unité organisationnelle a été supprimée avec succès.',
    };
  }
}