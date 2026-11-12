import { Module } from '@nestjs/common';
import { PromotionsModule } from '../promotions/promotions.module';
import { AttendanceController } from './attendance.controller';
import { AttendanceService } from './attendance.service';
import { AuditController } from './audit.controller';
import { AuditService } from './audit.service';
import { PermissionsController } from './permissions.controller';
import { ShiftsController } from './shifts.controller';
import { ShiftsService } from './shifts.service';

@Module({
  imports: [PromotionsModule],
  controllers: [ShiftsController, AttendanceController, AuditController, PermissionsController],
  providers: [ShiftsService, AttendanceService, AuditService],
  exports: [ShiftsService, AttendanceService, AuditService],
})
export class OperationsModule {}
