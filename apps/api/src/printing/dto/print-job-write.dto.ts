import { IsBoolean, IsUUID } from 'class-validator';

export class PrintJobWriteDto {
  @IsUUID()
  id!: string;

  @IsUUID()
  saleId!: string;

  @IsUUID()
  deviceId!: string;

  @IsUUID()
  printerConfigId!: string;

  @IsBoolean()
  copy!: boolean;
}
