import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsEnum,
  IsIn,
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
  ValidateNested,
} from 'class-validator';
import {
  ChannelOrderState,
  ChannelPaymentMode,
  CustomerConsentSource,
  CustomerContactType,
  OrderChannel,
} from '@prisma/client';
import { trim } from '../../common/transforms';

export const NON_NEGATIVE_INTEGER_PATTERN = /^(0|[1-9]\d{0,15})$/;

export class ChannelOrderLineDto {
  @IsUUID()
  variantId!: string;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(1000)
  quantity!: number;
}

export class ChannelCustomerDto {
  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(120)
  name?: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  contact!: string;

  @IsEnum(CustomerContactType)
  contactType!: CustomerContactType;

  @IsBoolean()
  consent!: boolean;

  @IsOptional()
  @IsEnum(CustomerConsentSource)
  consentSource?: CustomerConsentSource;
}

export class ChannelOrderWebhookDto {
  @IsUUID()
  outletId!: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  reference!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => ChannelOrderLineDto)
  items!: ChannelOrderLineDto[];

  @IsOptional()
  @ValidateNested()
  @Type(() => ChannelCustomerDto)
  customer?: ChannelCustomerDto;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(500)
  note?: string;

  @IsOptional()
  @IsEnum(ChannelPaymentMode)
  paymentMode?: ChannelPaymentMode;
}

export class ChannelOrderManualDto {
  @IsIn(['MANUAL', 'PHONE'])
  channel!: OrderChannel;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  reference!: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => ChannelOrderLineDto)
  items!: ChannelOrderLineDto[];

  @IsOptional()
  @ValidateNested()
  @Type(() => ChannelCustomerDto)
  customer?: ChannelCustomerDto;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(500)
  note?: string;

  @IsOptional()
  @IsEnum(ChannelPaymentMode)
  paymentMode?: ChannelPaymentMode;
}

export class ChannelOrderListQueryDto {
  @IsOptional()
  @IsEnum(ChannelOrderState)
  state?: ChannelOrderState;

  @IsOptional()
  @IsEnum(OrderChannel)
  channel?: OrderChannel;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(120)
  search?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}

export class ChannelOrderCancelDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(500)
  reason!: string;
}

export class ChannelOrderFulfillDto {
  @Transform(trim)
  @IsString()
  @Matches(NON_NEGATIVE_INTEGER_PATTERN)
  collectedMinor!: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(120)
  reference?: string;
}
