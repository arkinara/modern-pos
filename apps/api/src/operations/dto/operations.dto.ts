import { ShiftCashMovementKind, ShiftStatus, OperationAuditAction } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  IsEnum,
  IsInt,
  IsISO8601,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { trim } from '../../common/transforms';
import { MAX_SAFE_MINOR_NUMBER } from '../../sales/money';

export class ShiftOpenDto {
  @IsInt()
  @Min(0)
  @Max(MAX_SAFE_MINOR_NUMBER)
  openingFloatMinor!: number;
}

export class ShiftCashMovementDto {
  @IsEnum(ShiftCashMovementKind)
  kind!: ShiftCashMovementKind;

  @IsInt()
  @Min(1)
  @Max(MAX_SAFE_MINOR_NUMBER)
  amountMinor!: number;

  @Transform(trim)
  @IsString()
  @MinLength(1)
  @MaxLength(240)
  reason!: string;
}

export class ShiftCloseDto {
  @IsInt()
  @Min(0)
  @Max(MAX_SAFE_MINOR_NUMBER)
  countedCashMinor!: number;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(500)
  note?: string;
}

export class ShiftListQueryDto {
  @IsOptional()
  @IsEnum(ShiftStatus)
  status?: ShiftStatus;

  @IsOptional()
  @IsString()
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}

export class AttendanceClockDto {
  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(240)
  note?: string;
}

export class AttendanceListQueryDto {
  @IsOptional()
  @IsUUID()
  userId?: string;

  @IsOptional()
  @IsISO8601()
  from?: string;

  @IsOptional()
  @IsISO8601()
  to?: string;

  @IsOptional()
  @IsString()
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}

export class AuditSearchQueryDto {
  @IsOptional()
  @IsUUID()
  actorId?: string;

  @IsOptional()
  @IsISO8601()
  from?: string;

  @IsOptional()
  @IsISO8601()
  to?: string;

  @IsOptional()
  @IsEnum(OperationAuditAction)
  action?: OperationAuditAction;

  @IsOptional()
  @IsString()
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}
