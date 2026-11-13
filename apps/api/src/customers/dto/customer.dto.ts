import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { CustomerConsentSource, CustomerContactType } from '@prisma/client';
import { trim } from '../../common/transforms';

export class CustomerCreateDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(120)
  name!: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  contact!: string;

  @IsEnum(CustomerContactType)
  contactType!: CustomerContactType;

  @IsBoolean()
  consent!: boolean;

  @IsEnum(CustomerConsentSource)
  consentSource!: CustomerConsentSource;
}

export class CustomerListQueryDto {
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

export class RetentionPolicyUpdateDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(3650)
  customerRetentionDays!: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(3650)
  receiptRetentionDays!: number;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(10080)
  receiptLinkTtlMinutes!: number;
}
