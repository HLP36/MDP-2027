import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AppService {
  constructor(private readonly configService: ConfigService) {}

  getApplicationInfo() {
    return {
      application: this.configService.get<string>('APP_NAME'),
      organization: this.configService.get<string>('APP_ORGANIZATION'),
      version: this.configService.get<string>('APP_VERSION'),
      environment: this.configService.get<string>('NODE_ENV'),
      status: 'running',
    };
  }
}