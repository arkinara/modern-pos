import { StockBaseUnit } from '@prisma/client';
import { Transform } from 'class-transformer';
import { IsEnum, IsInt, IsNotEmpty, IsString, Matches, Max, MaxLength, Min } from 'class-validator';
import { trim } from '../../common/transforms';

export const NON_NEGATIVE_QUANTITY_PATTERN = /^(0|[1-9][0-9]{0,12})(\.[0-9]{1,6})?$/;

export class StockCreateDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  name!: string;

  @IsEnum(StockBaseUnit)
  baseUnit!: StockBaseUnit;

  @IsInt()
  @Min(0)
  @Max(6)
  quantityScale!: number;

  @IsString()
  @Matches(NON_NEGATIVE_QUANTITY_PATTERN)
  reorderThreshold!: string;
}
