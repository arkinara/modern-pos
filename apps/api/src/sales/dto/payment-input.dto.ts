import { PaymentKind } from '@prisma/client';
import { Transform } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, IsString, Max, MaxLength, Min } from 'class-validator';
import { trim } from '../../common/transforms';
import { MAX_SAFE_MINOR_NUMBER } from '../money';

export class PaymentInputDto {
  @IsEnum(PaymentKind)
  kind!: PaymentKind;

  @IsInt()
  @Min(0)
  @Max(MAX_SAFE_MINOR_NUMBER)
  amountMinor!: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(MAX_SAFE_MINOR_NUMBER)
  tenderedMinor?: number;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(200)
  reference?: string;
}
