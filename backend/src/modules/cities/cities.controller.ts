import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';

import { Permissions } from '../auth/decorators/permissions.decorator';
import { CitiesService } from './cities.service';
import { CreateCityDto } from './dto/create-city.dto';
import { UpdateCityDto } from './dto/update-city.dto';

@Controller('cities')
export class CitiesController {
  constructor(private readonly citiesService: CitiesService) {}

  @Get()
  @Permissions('cities.read')
  async findAll() {
    return this.citiesService.findAll();
  }

  @Get(':id')
  @Permissions('cities.read')
  async findOne(@Param('id') id: string) {
    return this.citiesService.findOne(id);
  }

  @Post()
  @Permissions('cities.create')
  async create(@Body() dto: CreateCityDto) {
    return this.citiesService.create(dto);
  }

  @Patch(':id')
  @Permissions('cities.update')
  async update(
    @Param('id') id: string,
    @Body() dto: UpdateCityDto,
  ) {
    return this.citiesService.update(id, dto);
  }

  @Delete(':id')
  @Permissions('cities.delete')
  async remove(@Param('id') id: string) {
    return this.citiesService.remove(id);
  }
}