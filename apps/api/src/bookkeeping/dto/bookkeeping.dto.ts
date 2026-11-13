import { CostingMethod } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { trim } from '../../common/transforms';

export const DATE_ONLY_PATTERN = /^\d{4}-\d{2}-\d{2}$/;
export const NON_NEGATIVE_INTEGER_PATTERN = /^(0|[1-9]\d{0,15})$/;

export class CostingUpdateDto {
  @IsEnum(CostingMethod)
  costingMethod!: CostingMethod;
}

export class ExpenseCategoryCreateDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MinLength(2)
  @MaxLength(100)
  name!: string;
}

export class ExpenseCreateDto {
  @IsUUID()
  categoryId!: string;

  @Transform(trim)
  @IsString()
  @Matches(NON_NEGATIVE_INTEGER_PATTERN)
  amountMinor!: string;

  @IsString()
  @Matches(DATE_ONLY_PATTERN)
  incurredOn!: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(500)
  note?: string;
}

export class ExpenseListQueryDto {
  @IsOptional()
  @IsString()
  @Matches(DATE_ONLY_PATTERN)
  from?: string;

  @IsOptional()
  @IsString()
  @Matches(DATE_ONLY_PATTERN)
  to?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}
