import { IsInt, IsUUID, Min } from 'class-validator';

export class OrderTransferDto {
  @IsInt()
  @Min(1)
  version!: number;

  @IsUUID()
  tableId!: string;
}
