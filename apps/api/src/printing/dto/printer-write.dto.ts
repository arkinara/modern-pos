import { Transform } from 'class-transformer';
import { IsIn, IsInt, IsNotEmpty, IsObject, IsString, IsUUID, MaxLength } from 'class-validator';
import { trim } from '../../common/transforms';

export const PRINTER_TRANSPORTS = ['BLUETOOTH', 'LAN', 'USB'] as const;
export type PrinterTransportValue = (typeof PRINTER_TRANSPORTS)[number];

export class PrinterWriteDto {
  @IsUUID()
  deviceId!: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  name!: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  model!: string;

  @IsString()
  @IsIn(PRINTER_TRANSPORTS)
  transport!: PrinterTransportValue;

  @IsInt()
  @IsIn([58, 80])
  paperWidthMm!: number;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  encoding!: string;

  @IsObject()
  connectionSettings!: Record<string, unknown>;
}
