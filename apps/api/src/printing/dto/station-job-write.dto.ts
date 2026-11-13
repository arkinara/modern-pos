import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsIn,
  IsInt,
  IsObject,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';

export const STATION_JOB_KINDS = ['ORIGINAL', 'AMEND', 'CANCEL'] as const;
export type StationJobKindValue = (typeof STATION_JOB_KINDS)[number];

export const STATION_JOB_STATES = ['QUEUED', 'SENDING', 'SENT', 'FAILED', 'UNKNOWN'] as const;
export type StationJobStateValue = (typeof STATION_JOB_STATES)[number];

export class StationJobLineDto {
  @IsUUID()
  variantId!: string;

  @IsInt()
  @Min(1)
  @Max(100_000)
  quantity!: number;

  @IsOptional()
  @IsUUID()
  saleLineId?: string;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20)
  @IsObject({ each: true })
  modifiers?: Record<string, unknown>[];
}

export class StationJobWriteDto {
  @IsString()
  @IsIn(STATION_JOB_KINDS)
  kind!: StationJobKindValue;

  @IsOptional()
  @IsUUID()
  saleId?: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => StationJobLineDto)
  lines!: StationJobLineDto[];
}

export class StationJobStateDto {
  @IsString()
  @IsIn(STATION_JOB_STATES)
  state!: StationJobStateValue;

  @IsInt()
  @Min(0)
  attempts!: number;

  @IsOptional()
  @IsString()
  @MaxLength(1000)
  lastError?: string | null;
}
