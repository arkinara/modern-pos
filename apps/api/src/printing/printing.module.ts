import { Module } from '@nestjs/common';
import { PrintingController } from './printing.controller';
import { PrintingService } from './printing.service';
import { StationRoutingController } from './station-routing.controller';
import { StationRoutingService } from './station-routing.service';

@Module({
  controllers: [PrintingController, StationRoutingController],
  providers: [PrintingService, StationRoutingService],
})
export class PrintingModule {}
