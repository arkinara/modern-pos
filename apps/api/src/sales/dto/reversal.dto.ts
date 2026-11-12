import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { trim } from '../../common/transforms';
import { MAX_SAFE_MINOR_NUMBER } from '../money';

export const FIXED_POINT_PATTERN = /^(0|[1-9][0-9]{0,12})(\.[0-9]{1,6})?$/;

export class RestockItemDto {
  @IsUUID()
  stockItemId!: string;

  @IsString()
  @Matches(FIXED_POINT_PATTERN, {
    message: 'quantity must be a nonnegative fixed-point base-unit string',
  })
  quantity!: string;
}

export class RefundLineDto {
  @IsUUID()
  saleLineId!: string;

  @IsInt()
  @Min(1)
  @Max(100_000)
  quantity!: number;
}

export class ReversalDto {
  @Transform(trim)
  @IsString()
  @MinLength(3)
  @MaxLength(500)
  reason!: string;

  @IsArray()
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => RestockItemDto)
  restock!: RestockItemDto[];

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(MAX_SAFE_MINOR_NUMBER)
  refundMinor?: number;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => RefundLineDto)
  lines?: RefundLineDto[];
}
