import {
  Body,
  Controller,
  Get,
  Headers,
  Post,
  Req,
} from '@nestjs/common';

import { Request } from 'express';

import { AuthService } from './auth.service';

import { LoginDto } from './dto/login.dto';
import { RefreshTokenDto } from './dto/refresh-token.dto';

import { Public } from './decorators/public.decorator';
import { CurrentUser } from './decorators/current-user.decorator';

@Controller('auth')
export class AuthController {
  constructor(
    private readonly authService: AuthService,
  ) {}

  @Public()
  @Post('login')
  login(
    @Body() dto: LoginDto,
    @Req() request: Request,
  ) {
    return this.authService.login(
      dto,
      request.ip,
      request.headers['user-agent'],
    );
  }

  @Get('me')
  me(@CurrentUser() user: any) {
    return this.authService.me(user.id);
  }

  @Public()
  @Post('refresh')
  refresh(@Body() dto: RefreshTokenDto) {
    return this.authService.refresh(
      dto.refreshToken,
    );
  }

  @Post('logout')
  logout(
    @CurrentUser() user: any,
    @Headers('user-agent') userAgent?: string,
    @Req() request?: Request,
  ) {
    return this.authService.logout(
      user.id,
      user.sessionId,
      request?.ip,
      userAgent,
    );
  }
}