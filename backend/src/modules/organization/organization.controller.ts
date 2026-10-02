import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';

import { OrganizationService } from './organization.service';

import { CreateOrganizationalUnitDto } from './dto/create-organizational-unit.dto';

import { UpdateOrganizationalUnitDto } from './dto/update-organizational-unit.dto';

import { QueryOrganizationalUnitDto } from './dto/query-organizational-unit.dto';

import { Permissions } from '../auth/decorators/permissions.decorator';

// ======================================================
// ORGANIZATION CONTROLLER
// ======================================================

@Controller('organization')
export class OrganizationController {
  constructor(
    private readonly organizationService: OrganizationService,
  ) {}

  // ====================================================
  // GET ORGANIZATIONAL TREE
  //
  // GET /api/organization/tree
  // Permission: organization.read
  // ====================================================

  @Get('tree')
  @Permissions('organization.read')
  async getTree() {
    return this.organizationService.getTree();
  }

  // ====================================================
  // GET ORGANIZATION OVERVIEW
  //
  // GET /api/organization/overview
  // Permission: organization.read
  //
  // Used by the Organization Command Center
  // ====================================================

  @Get('overview')
  @Permissions('organization.read')
  async getOverview() {
    return this.organizationService.getOverview();
  }

  // ====================================================
  // GET ALL ORGANIZATIONAL UNITS
  //
  // GET /api/organization
  // Permission: organization.read
  // ====================================================

  @Get()
  @Permissions('organization.read')
  async findAll(
    @Query()
    query: QueryOrganizationalUnitDto,
  ) {
    return this.organizationService.findAll(
      query,
    );
  }

  // ====================================================
  // GET ONE ORGANIZATIONAL UNIT
  //
  // GET /api/organization/:id
  // Permission: organization.read
  // ====================================================

  @Get(':id')
  @Permissions('organization.read')
  async findOne(
    @Param('id')
    id: string,
  ) {
    return this.organizationService.findOne(
      id,
    );
  }

  // ====================================================
  // CREATE ORGANIZATIONAL UNIT
  //
  // POST /api/organization
  // Permission: organization.create
  // ====================================================

  @Post()
  @Permissions('organization.create')
  async create(
    @Body()
    createDto: CreateOrganizationalUnitDto,
  ) {
    return this.organizationService.create(
      createDto,
    );
  }

  // ====================================================
  // UPDATE ORGANIZATIONAL UNIT
  //
  // PATCH /api/organization/:id
  // Permission: organization.update
  // ====================================================

  @Patch(':id')
  @Permissions('organization.update')
  async update(
    @Param('id')
    id: string,

    @Body()
    updateDto: UpdateOrganizationalUnitDto,
  ) {
    return this.organizationService.update(
      id,
      updateDto,
    );
  }

  // ====================================================
  // DELETE ORGANIZATIONAL UNIT
  //
  // DELETE /api/organization/:id
  // Permission: organization.delete
  // ====================================================

  @Delete(':id')
  @Permissions('organization.delete')
  async remove(
    @Param('id')
    id: string,
  ) {
    return this.organizationService.remove(
      id,
    );
  }
}