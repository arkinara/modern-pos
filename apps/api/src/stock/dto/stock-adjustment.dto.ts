import { Transform } from 'class-transformer';
import {
  IsInt,
  IsNotEmpty,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { trim } from '../../common/transforms';

export const SIGNED_QUANTITY_PATTERN = /^-?(0|[1-9][0-9]{0,12})(\.[0-9]{1,6})?$/;

export class StockAdjustmentDto {
  @IsUUID()
  stockItemId!: string;

  @IsString()
  @Matches(SIGNED_QUANTITY_PATTERN)
  delta!: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(500)
  reason!: string;

  @IsInt()
  @Min(1)
  expectedBalanceVersion!: number;
}
