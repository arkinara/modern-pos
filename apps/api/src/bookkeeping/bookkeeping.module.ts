import { Module } from '@nestjs/common';
import { ReportsModule } from '../reports/reports.module';
import { BookkeepingController } from './bookkeeping.controller';
import { BookkeepingService } from './bookkeeping.service';

@Module({
  imports: [ReportsModule],
  controllers: [BookkeepingController],
  providers: [BookkeepingService],
  exports: [BookkeepingService],
})
export class BookkeepingModule {}
