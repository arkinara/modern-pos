import {
  Body,
  Controller,
  Get,
  Headers,
  HttpCode,
  Param,
  Patch,
  Post,
  Put,
  Query,
} from '@nestjs/common';
import { Role } from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Roles } from '../common/decorators/roles.decorator';
import { PrintJobStateDto } from './dto/print-job-state.dto';
import { PrintJobWriteDto } from './dto/print-job-write.dto';
import { PrinterUpdateDto } from './dto/printer-update.dto';
import { PrinterWriteDto } from './dto/printer-write.dto';
import { PrintJobResponse, PrinterResponse, PrintingService } from './printing.service';

@Controller('outlets/:outletId')
export class PrintingController {
  constructor(private readonly printing: PrintingService) {}

  @Roles(Role.OWNER, Role.CASHIER)
  @Get('printers')
  listPrinters(
    @Param('outletId') outletId: string,
    @Query('deviceId') deviceId: string,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PrinterResponse[]> {
    return this.printing.listPrinters(outletId, deviceId, user);
  }

  @Roles(Role.OWNER)
  @Post('printers')
  @HttpCode(201)
  createPrinter(
    @Param('outletId') outletId: string,
    @Body() dto: PrinterWriteDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PrinterResponse> {
    return this.printing.createPrinter(outletId, dto, user);
  }

  @Roles(Role.OWNER)
  @Put('printers/:printerId')
  updatePrinter(
    @Param('outletId') outletId: string,
    @Param('printerId') printerId: string,
    @Body() dto: PrinterUpdateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PrinterResponse> {
    return this.printing.updatePrinter(outletId, printerId, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Post('print-jobs')
  @HttpCode(201)
  createJob(
    @Param('outletId') outletId: string,
    @Headers('Idempotency-Key') key: string | undefined,
    @Body() dto: PrintJobWriteDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PrintJobResponse> {
    return this.printing.createJob(outletId, key, dto, user);
  }

  @Roles(Role.OWNER, Role.CASHIER)
  @Patch('print-jobs/:jobId')
  updateState(
    @Param('outletId') outletId: string,
    @Param('jobId') jobId: string,
    @Body() dto: PrintJobStateDto,
    @CurrentUser() user: AuthenticatedUser,
  ): Promise<PrintJobResponse> {
    return this.printing.updateJobState(outletId, jobId, dto, user);
  }
}
