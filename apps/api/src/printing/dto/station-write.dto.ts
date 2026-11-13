import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
} from 'class-validator';
import { trim } from '../../common/transforms';

export const STATION_KINDS = ['KITCHEN', 'BAR', 'COLD', 'HOT', 'OTHER'] as const;
export type StationKindValue = (typeof STATION_KINDS)[number];

export class StationWriteDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name!: string;

  @IsString()
  @IsIn(STATION_KINDS)
  kind!: StationKindValue;

  @IsOptional()
  @IsUUID()
  printerConfigId?: string;

  @IsBoolean()
  isDefault!: boolean;

  @IsInt()
  @Min(0)
  sortOrder!: number;
}
