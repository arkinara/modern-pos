import { IsInt, Min } from 'class-validator';
import { PrinterWriteDto } from './printer-write.dto';

export class PrinterUpdateDto extends PrinterWriteDto {
  @IsInt()
  @Min(1)
  revision!: number;
}
