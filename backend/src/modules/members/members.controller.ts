import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';

import { MembersService } from './members.service';

import { CreateMemberDto } from './dto/create-member.dto';
import { UpdateMemberDto } from './dto/update-member.dto';

import { Permissions } from '../auth/decorators/permissions.decorator';

@Controller('members')
export class MembersController {
  constructor(
    private readonly membersService: MembersService,
  ) {}

  // ======================================================
  // GET ALL MEMBERS
  // GET /api/members
  // ======================================================

  @Get()
  @Permissions('members.read')
  async findAll() {
    return this.membersService.findAll();
  }

  // ======================================================
  // GET ONE MEMBER
  // GET /api/members/:id
  // ======================================================

  @Get(':id')
  @Permissions('members.read')
  async findOne(
    @Param('id') id: string,
  ) {
    return this.membersService.findOne(id);
  }

  // ======================================================
  // CREATE MEMBER
  // POST /api/members
  // ======================================================

  @Post()
  @Permissions('members.create')
  async create(
    @Body()
    createDto: CreateMemberDto,
  ) {
    return this.membersService.create(
      createDto,
    );
  }

  // ======================================================
  // UPDATE MEMBER
  // PATCH /api/members/:id
  // ======================================================

  @Patch(':id')
  @Permissions('members.update')
  async update(
    @Param('id') id: string,

    @Body()
    updateDto: UpdateMemberDto,
  ) {
    return this.membersService.update(
      id,
      updateDto,
    );
  }

  // ======================================================
  // DEACTIVATE MEMBER
  // DELETE /api/members/:id
  // ======================================================

  @Delete(':id')
  @Permissions('members.delete')
  async remove(
    @Param('id') id: string,
  ) {
    return this.membersService.remove(id);
  }
}