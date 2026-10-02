import {
  IsBoolean,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';

import { OrganizationalUnitType } from '../../../generated/prisma';

// ======================================================
// CREATE ORGANIZATIONAL UNIT DTO
// ======================================================

export class CreateOrganizationalUnitDto {
  // ======================================================
  // NAME
  // ======================================================

  @IsString({
    message: 'Le nom doit être une chaîne de caractères.',
  })
  @MinLength(2, {
    message: 'Le nom doit contenir au moins 2 caractères.',
  })
  @MaxLength(150, {
    message: 'Le nom ne peut pas dépasser 150 caractères.',
  })
  name!: string;

  // ======================================================
  // TYPE
  // ======================================================

  @IsEnum(OrganizationalUnitType, {
    message:
      'Le type doit être une unité organisationnelle valide.',
  })
  type!: OrganizationalUnitType;

  // ======================================================
  // DESCRIPTION
  // ======================================================

  @IsOptional()
  @IsString({
    message:
      'La description doit être une chaîne de caractères.',
  })
  @MaxLength(1000, {
    message:
      'La description ne peut pas dépasser 1000 caractères.',
  })
  description?: string;

  // ======================================================
  // PARENT
  // ======================================================

  @IsOptional()
  @IsUUID('4', {
    message:
      'parentId doit être un UUID valide.',
  })
  parentId?: string;

  // ======================================================
  // LEADER
  // ======================================================

  @IsOptional()
  @IsUUID('4', {
    message:
      'leaderId doit être un UUID valide.',
  })
  leaderId?: string;

  // ======================================================
  // STATUS
  // ======================================================

  @IsOptional()
  @IsBoolean({
    message:
      'isActive doit être une valeur booléenne.',
  })
  isActive?: boolean;
}