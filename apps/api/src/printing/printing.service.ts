import { Injectable } from '@nestjs/common';
import {
  Prisma,
  Role,
  type PrintJob as PrintJobRow,
  type Printer as PrinterRow,
} from '@prisma/client';
import type { AuthenticatedUser } from '../auth/auth.types';
import { apiError } from '../common/api-error';
import { PrismaService } from '../prisma/prisma.service';
import { PrintJobStateDto } from './dto/print-job-state.dto';
import { PrintJobWriteDto } from './dto/print-job-write.dto';
import { PrinterUpdateDto } from './dto/printer-update.dto';
import { PrinterWriteDto } from './dto/printer-write.dto';

export interface PrinterResponse {
  id: string;
  deviceId: string;
  name: string;
  model: string;
  transport: 'BLUETOOTH' | 'LAN' | 'USB';
  paperWidthMm: number;
  encoding: string;
  revision: number;
}

export interface PrintJobResponse {
  id: string;
  saleId: string;
  deviceId: string;
  state: 'QUEUED' | 'SENDING' | 'SENT' | 'FAILED' | 'UNKNOWN';
  copy: boolean;
  attempts: number;
  lastError: string | null;
}

const UUID_PATTERN = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

@Injectable()
export class PrintingService {
  constructor(private readonly prisma: PrismaService) {}

  async listPrinters(
    outletId: string,
    deviceId: string | undefined,
    user: AuthenticatedUser,
  ): Promise<PrinterResponse[]> {
    const scopedDeviceId = deviceId?.trim();

    if (scopedDeviceId) {
      if (!UUID_PATTERN.test(scopedDeviceId)) {
        throw apiError(400, 'VALIDATION_ERROR', 'A valid deviceId query parameter is required');
      }
    } else if (user.role !== Role.OWNER) {
      throw apiError(400, 'VALIDATION_ERROR', 'A valid deviceId query parameter is required');
    }

    await this.assertOutlet(outletId, user);

    const printers = await this.prisma.printer.findMany({
      where: {
        businessId: user.businessId,
        outletId,
        ...(scopedDeviceId ? { deviceId: scopedDeviceId } : {}),
      },
      orderBy: [{ name: 'asc' }, { createdAt: 'asc' }],
    });
    return printers.map((printer) => this.toPrinterResponse(printer));
  }

  async createPrinter(
    outletId: string,
    dto: PrinterWriteDto,
    user: AuthenticatedUser,
  ): Promise<PrinterResponse> {
    await this.assertOutlet(outletId, user);

    try {
      const printer = await this.prisma.printer.create({
        data: {
          businessId: user.businessId,
          outletId,
          deviceId: dto.deviceId,
          name: dto.name,
          model: dto.model,
          transport: dto.transport,
          paperWidthMm: dto.paperWidthMm,
          encoding: dto.encoding,
          connectionSettings: this.connectionSettings(dto.connectionSettings),
        },
      });
      return this.toPrinterResponse(printer);
    } catch (error) {
      if (this.isUniqueViolation(error)) {
        throw apiError(
          409,
          'PRINTER_EXISTS',
          'A printer with this name already exists for the device',
        );
      }
      throw error;
    }
  }

  async updatePrinter(
    outletId: string,
    printerId: string,
    dto: PrinterUpdateDto,
    user: AuthenticatedUser,
  ): Promise<PrinterResponse> {
    await this.assertOutlet(outletId, user);

    const existing = await this.prisma.printer.findFirst({
      where: { id: printerId, businessId: user.businessId, outletId },
    });
    if (!existing) {
      throw apiError(404, 'NOT_FOUND', 'Printer not found');
    }
    if (existing.revision !== dto.revision) {
      throw apiError(
        409,
        'VERSION_CONFLICT',
        'Printer configuration was changed by another request',
      );
    }

    const updated = await this.prisma.printer.updateMany({
      where: {
        id: printerId,
        businessId: user.businessId,
        outletId,
        revision: dto.revision,
      },
      data: {
        deviceId: dto.deviceId,
        name: dto.name,
        model: dto.model,
        transport: dto.transport,
        paperWidthMm: dto.paperWidthMm,
        encoding: dto.encoding,
        connectionSettings: this.connectionSettings(dto.connectionSettings),
        revision: { increment: 1 },
      },
    });

    if (updated.count !== 1) {
      throw apiError(
        409,
        'VERSION_CONFLICT',
        'Printer configuration was changed by another request',
      );
    }

    const printer = await this.prisma.printer.findFirst({
      where: { id: printerId, businessId: user.businessId, outletId },
    });
    if (!printer) {
      throw apiError(404, 'NOT_FOUND', 'Printer not found');
    }
    return this.toPrinterResponse(printer);
  }

  async createJob(
    outletId: string,
    idempotencyKey: string | undefined,
    dto: PrintJobWriteDto,
    user: AuthenticatedUser,
  ): Promise<PrintJobResponse> {
    await this.assertOutlet(outletId, user);
    if (!idempotencyKey || !UUID_PATTERN.test(idempotencyKey)) {
      throw apiError(400, 'VALIDATION_ERROR', 'A UUID Idempotency-Key header is required');
    }

    const [sale, printer, existing] = await Promise.all([
      this.prisma.sale.findFirst({
        where: { id: dto.saleId, businessId: user.businessId, outletId },
        select: { id: true, deviceId: true },
      }),
      this.prisma.printer.findFirst({
        where: { id: dto.printerConfigId, businessId: user.businessId, outletId },
        select: { id: true, deviceId: true },
      }),
      this.prisma.printJob.findFirst({
        where: { outletId, deviceId: dto.deviceId, idempotencyKey },
      }),
    ]);
    if (!sale || sale.deviceId !== dto.deviceId) {
      throw apiError(404, 'SALE_NOT_FOUND', 'Sale not found for this device');
    }
    if (!printer || printer.deviceId !== dto.deviceId) {
      throw apiError(404, 'PRINTER_NOT_FOUND', 'Printer configuration not found for this device');
    }
    if (existing) {
      const sameRequest =
        existing.id === dto.id &&
        existing.saleId === dto.saleId &&
        existing.printerConfigId === dto.printerConfigId &&
        existing.copy === dto.copy;
      if (!sameRequest) {
        throw apiError(
          409,
          'IDEMPOTENCY_CONFLICT',
          'The idempotency key was used for another print job',
        );
      }
      return this.toJobResponse(existing);
    }

    try {
      const job = await this.prisma.printJob.create({
        data: {
          id: dto.id,
          businessId: user.businessId,
          outletId,
          saleId: dto.saleId,
          deviceId: dto.deviceId,
          printerConfigId: dto.printerConfigId,
          idempotencyKey,
          copy: dto.copy,
        },
      });
      return this.toJobResponse(job);
    } catch (error) {
      if (this.isUniqueViolation(error)) {
        throw apiError(409, 'PRINT_JOB_EXISTS', 'This print job already exists');
      }
      throw error;
    }
  }

  async updateJobState(
    outletId: string,
    jobId: string,
    dto: PrintJobStateDto,
    user: AuthenticatedUser,
  ): Promise<PrintJobResponse> {
    await this.assertOutlet(outletId, user);

    const job = await this.prisma.printJob.findFirst({
      where: { id: jobId, businessId: user.businessId, outletId },
    });
    if (!job || job.deviceId !== dto.deviceId) {
      // Device ownership is enforced as 404 so another device cannot probe
      // whether the job exists.
      throw apiError(404, 'NOT_FOUND', 'Print job not found');
    }

    const updated = await this.prisma.printJob.update({
      where: { id: jobId },
      data: {
        state: dto.state,
        attempts: dto.attempts,
        lastError: dto.lastError,
      },
    });
    return this.toJobResponse(updated);
  }

  private async assertOutlet(outletId: string, user: AuthenticatedUser): Promise<void> {
    const outlet = await this.prisma.outlet.findFirst({
      where: { id: outletId, businessId: user.businessId },
      select: { id: true },
    });
    if (!outlet) {
      throw apiError(404, 'NOT_FOUND', 'Outlet not found');
    }
  }

  private connectionSettings(value: Record<string, unknown>): Prisma.InputJsonValue {
    const normalized: Record<string, string> = {};
    for (const [key, entry] of Object.entries(value)) {
      normalized[key] = typeof entry === 'string' ? entry : String(entry);
    }
    return normalized;
  }

  private isUniqueViolation(error: unknown): boolean {
    return error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002';
  }

  private toPrinterResponse(printer: PrinterRow): PrinterResponse {
    return {
      id: printer.id,
      deviceId: printer.deviceId,
      name: printer.name,
      model: printer.model,
      transport: printer.transport,
      paperWidthMm: printer.paperWidthMm,
      encoding: printer.encoding,
      revision: printer.revision,
    };
  }

  private toJobResponse(job: PrintJobRow): PrintJobResponse {
    return {
      id: job.id,
      saleId: job.saleId,
      deviceId: job.deviceId,
      state: job.state,
      copy: job.copy,
      attempts: job.attempts,
      lastError: job.lastError,
    };
  }
}
