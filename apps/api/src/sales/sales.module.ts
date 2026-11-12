import { Module } from '@nestjs/common';
import { PromotionsModule } from '../promotions/promotions.module';
import { SalesController } from './sales.controller';
import { SalesService } from './sales.service';

@Module({
  imports: [PromotionsModule],
  controllers: [SalesController],
  providers: [SalesService],
})
export class SalesModule {}
