import { Type } from 'class-transformer';
import { IsInt, IsOptional, IsString, Matches, Max, Min } from 'class-validator';

export const SETTLEMENT_DATE_ONLY_PATTERN = /^\d{4}-\d{2}-\d{2}$/;

export class SettlementQueryDto {
  @IsString()
  @Matches(SETTLEMENT_DATE_ONLY_PATTERN)
  from!: string;

  @IsString()
  @Matches(SETTLEMENT_DATE_ONLY_PATTERN)
  to!: string;
}

export class PaymentListQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}
