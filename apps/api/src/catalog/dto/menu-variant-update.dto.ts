import { StockPolicy } from '@prisma/client';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { trim } from '../../common/transforms';
import { MAX_PRICE_MINOR } from './menu-variant-write.dto';

export class MenuVariantUpdateDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  name!: string;

  @IsInt()
  @Min(0)
  @Max(MAX_PRICE_MINOR)
  priceMinor!: number;

  @IsEnum(StockPolicy)
  stockPolicy!: StockPolicy;

  @IsBoolean()
  enabled!: boolean;

  @IsInt()
  @Min(1)
  revision!: number;
}
