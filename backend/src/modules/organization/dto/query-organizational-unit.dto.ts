import {
  IsBooleanString,
  IsEnum,
  IsOptional,
  IsUUID,
} from 'class-validator';

import { OrganizationalUnitType } from '@prisma/client';

// ======================================================
// QUERY ORGANIZATIONAL UNIT DTO
// ======================================================

export class QueryOrganizationalUnitDto {
  // ======================================================
  // TYPE
  // ======================================================

  @IsOptional()
  @IsEnum(OrganizationalUnitType, {
    message:
      'Le type doit être une unité organisationnelle valide.',
  })
  type?: OrganizationalUnitType;

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
  // ACTIVE STATUS
  // ======================================================

  @IsOptional()
  @IsBooleanString({
    message:
      'isActive doit être true ou false.',
  })
  isActive?: string;
}