import { StockPolicy } from '@prisma/client';
import { Transform } from 'class-transformer';
import { IsEnum, IsInt, IsNotEmpty, IsString, Max, MaxLength, Min } from 'class-validator';
import { trim } from '../../common/transforms';

export const MAX_PRICE_MINOR = 9_007_199_254_740_991;

export class MenuVariantWriteDto {
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
}
