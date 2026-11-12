import { PromotionKind, PromotionStacking } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsBoolean,
  IsEmail,
  IsEnum,
  IsInt,
  IsISO8601,
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
import { FIXED_POINT_PATTERN } from '../../sales/dto/reversal.dto';
import { MAX_SAFE_MINOR_NUMBER } from '../../sales/money';

export class PromotionEligibilityDto {
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(500)
  @IsUUID('4', { each: true })
  variantIds?: string[];

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(500)
  @IsUUID('4', { each: true })
  menuItemIds?: string[];

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(500)
  @IsEmail({}, { each: true })
  customerEmails?: string[];
}

export class PromotionCreateDto {
  @Transform(trim)
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  name!: string;

  @IsEnum(PromotionKind)
  kind!: PromotionKind;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(10_000)
  percentageBps?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(MAX_SAFE_MINOR_NUMBER)
  amountMinor?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(MAX_SAFE_MINOR_NUMBER)
  minBasketMinor?: number;

  @IsOptional()
  @IsISO8601()
  startsAt?: string;

  @IsOptional()
  @IsISO8601()
  endsAt?: string;

  @IsOptional()
  @IsBoolean()
  active?: boolean;

  @IsOptional()
  @IsEnum(PromotionStacking)
  stacking?: PromotionStacking;

  @IsOptional()
  @IsInt()
  @Min(-1_000)
  @Max(1_000)
  priority?: number;

  @IsOptional()
  @ValidateNested()
  @Type(() => PromotionEligibilityDto)
  eligibility?: PromotionEligibilityDto;
}

export class PromotionUpdateDto extends PromotionCreateDto {
  @IsInt()
  @Min(1)
  revision!: number;
}

export class ModifierCreateDto {
  @IsUUID()
  menuItemId!: string;

  @Transform(trim)
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  name!: string;

  @IsInt()
  @Min(-MAX_SAFE_MINOR_NUMBER)
  @Max(MAX_SAFE_MINOR_NUMBER)
  priceDeltaMinor!: number;

  @IsOptional()
  @IsUUID()
  stockItemId?: string;

  @IsOptional()
  @IsString()
  @Matches(FIXED_POINT_PATTERN, {
    message: 'quantityPerSaleUnit must be a nonnegative fixed-point base-unit string',
  })
  quantityPerSaleUnit?: string;

  @IsOptional()
  @IsBoolean()
  active?: boolean;
}

export class ApprovalRuleUpsertDto {
  @IsInt()
  @Min(0)
  @Max(MAX_SAFE_MINOR_NUMBER)
  thresholdMinor!: number;

  @IsOptional()
  @IsBoolean()
  active?: boolean;
}
