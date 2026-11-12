import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { AuthModule } from './auth/auth.module';
import { CatalogModule } from './catalog/catalog.module';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';
import { OutletScopeGuard } from './common/guards/outlet-scope.guard';
import { RolesGuard } from './common/guards/roles.guard';
import { RequestIdMiddleware } from './common/request-id.middleware';
import { HealthController } from './health/health.controller';
import { OutletsModule } from './outlets/outlets.module';
import { PrintingModule } from './printing/printing.module';
import { PrismaModule } from './prisma/prisma.module';
import { PromotionsModule } from './promotions/promotions.module';
import { RecipeModule } from './recipe/recipe.module';
import { ReportsModule } from './reports/reports.module';
import { SalesModule } from './sales/sales.module';
import { SettingsModule } from './settings/settings.module';
import { StockModule } from './stock/stock.module';

@Module({
  imports: [
    PrismaModule,
    AuthModule,
    OutletsModule,
    SettingsModule,
    CatalogModule,
    StockModule,
    RecipeModule,
    SalesModule,
    PromotionsModule,
    ReportsModule,
    PrintingModule,
  ],
  controllers: [HealthController],
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: OutletScopeGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    consumer.apply(RequestIdMiddleware).forRoutes('*');
  }
}
