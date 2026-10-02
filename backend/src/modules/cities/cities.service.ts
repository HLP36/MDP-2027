import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';

import { PrismaService } from '../../prisma/prisma.service';

import { CreateCityDto } from './dto/create-city.dto';
import { UpdateCityDto } from './dto/update-city.dto';

@Injectable()
export class CitiesService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Liste les villes.
   *
   * Par défaut, seules les villes actives sont retournées.
   */
  async findAll(includeInactive = false) {
    return this.prisma.city.findMany({
      where: includeInactive
        ? undefined
        : {
            isActive: true,
          },
      orderBy: {
        name: 'asc',
      },
      include: {
        _count: {
          select: {
            members: true,
          },
        },
      },
    });
  }

  /**
   * Recherche une ville par son ID.
   */
  async findOne(id: string) {
    const city = await this.prisma.city.findUnique({
      where: {
        id,
      },
      include: {
        _count: {
          select: {
            members: true,
          },
        },
      },
    });

    if (!city) {
      throw new NotFoundException(
        'La ville demandée est introuvable.',
      );
    }

    return city;
  }

  /**
   * Création d'une ville.
   */
  async create(dto: CreateCityDto) {
    const name = dto.name.trim();
    const code = dto.code.trim().toUpperCase();

    const existing = await this.prisma.city.findFirst({
      where: {
        OR: [
          {
            name: {
              equals: name,
              mode: 'insensitive',
            },
          },
          {
            code: {
              equals: code,
              mode: 'insensitive',
            },
          },
        ],
      },
    });

    if (existing) {
      throw new ConflictException(
        'Une ville avec ce nom ou ce code existe déjà.',
      );
    }

    return this.prisma.city.create({
      data: {
        name,
        code,
        country: dto.country?.trim() || null,
        isActive: dto.isActive ?? true,
      },
      include: {
        _count: {
          select: {
            members: true,
          },
        },
      },
    });
  }

  /**
   * Modification d'une ville.
   */
  async update(id: string, dto: UpdateCityDto) {
    await this.findOne(id);

    const name =
      dto.name !== undefined
        ? dto.name.trim()
        : undefined;

    const code =
      dto.code !== undefined
        ? dto.code.trim().toUpperCase()
        : undefined;

    /*
     * Vérification des doublons.
     */
    if (name !== undefined || code !== undefined) {
      const duplicateConditions: Array<
        | {
            name: {
              equals: string;
              mode: 'insensitive';
            };
          }
        | {
            code: {
              equals: string;
              mode: 'insensitive';
            };
          }
      > = [];

      if (name !== undefined) {
        duplicateConditions.push({
          name: {
            equals: name,
            mode: 'insensitive',
          },
        });
      }

      if (code !== undefined) {
        duplicateConditions.push({
          code: {
            equals: code,
            mode: 'insensitive',
          },
        });
      }

      const existing = await this.prisma.city.findFirst({
        where: {
          id: {
            not: id,
          },
          OR: duplicateConditions,
        },
      });

      if (existing) {
        throw new ConflictException(
          'Une autre ville utilise déjà ce nom ou ce code.',
        );
      }
    }

    return this.prisma.city.update({
      where: {
        id,
      },
      data: {
        ...(name !== undefined && {
          name,
        }),

        ...(code !== undefined && {
          code,
        }),

        ...(dto.country !== undefined && {
          country: dto.country.trim() || null,
        }),

        ...(dto.isActive !== undefined && {
          isActive: dto.isActive,
        }),
      },
      include: {
        _count: {
          select: {
            members: true,
          },
        },
      },
    });
  }

  /**
   * Suppression d'une ville.
   *
   * Si des membres sont encore rattachés à la ville,
   * la ville est désactivée au lieu d'être supprimée.
   */
  async remove(id: string) {
    const city = await this.findOne(id);

    if (city._count.members > 0) {
      return this.prisma.city.update({
        where: {
          id,
        },
        data: {
          isActive: false,
        },
        include: {
          _count: {
            select: {
              members: true,
            },
          },
        },
      });
    }

    return this.prisma.city.delete({
      where: {
        id,
      },
    });
  }
}