import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { AuthModule } from './auth/auth.module';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { OutletScopeGuard } from './common/guards/outlet-scope.guard';
import { RolesGuard } from './common/guards/roles.guard';
import { RequestIdMiddleware } from './common/request-id.middleware';
import { HealthController } from './health/health.controller';
import { OutletsModule } from './outlets/outlets.module';
import { PrismaModule } from './prisma/prisma.module';
import { SettingsModule } from './settings/settings.module';

@Module({
  imports: [PrismaModule, AuthModule, OutletsModule, SettingsModule],
  controllers: [HealthController],
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
    { provide: APP_GUARD, useClass: OutletScopeGuard },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(RequestIdMiddleware).forRoutes('*');
  }
}
