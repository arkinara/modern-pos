import { TransferState, WasteReason } from '@prisma/client';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsEnum,
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
import { trim } from '../../common/transforms';
import { NON_NEGATIVE_QUANTITY_PATTERN } from '../../stock/dto/stock-create.dto';

export enum PurchaseOrderReceiptUnit {
  SUPPLIER = 'SUPPLIER',
  BASE = 'BASE',
}

export class SupplierCreateDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  name!: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(100)
  reference?: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(300)
  contact?: string;
}

export class SupplierListQueryDto {
  @IsOptional()
  @IsUUID()
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(100)
  search?: string;
}

export class PurchaseOrderLineWriteDto {
  @IsUUID()
  stockItemId!: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(50)
  supplierUnit!: string;

  @IsString()
  @Matches(NON_NEGATIVE_QUANTITY_PATTERN)
  unitsPerSupplierUnit!: string;

  @IsString()
  @Matches(NON_NEGATIVE_QUANTITY_PATTERN)
  orderedQuantity!: string;

  @IsString()
  @Matches(NON_NEGATIVE_QUANTITY_PATTERN)
  unitPrice!: string;
}

export class PurchaseOrderCreateDto {
  @IsUUID()
  supplierId!: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(100)
  reference?: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => PurchaseOrderLineWriteDto)
  lines!: PurchaseOrderLineWriteDto[];
}

export class PurchaseOrderListQueryDto {
  @IsOptional()
  @IsUUID()
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}

export class PurchaseOrderReceiptDto {
  @IsUUID()
  lineId!: string;

  @IsString()
  @Matches(NON_NEGATIVE_QUANTITY_PATTERN)
  quantity!: string;

  @IsEnum(PurchaseOrderReceiptUnit)
  unit!: PurchaseOrderReceiptUnit;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(300)
  note?: string;
}

export class StockCountLineWriteDto {
  @IsUUID()
  stockItemId!: string;

  @IsString()
  @Matches(NON_NEGATIVE_QUANTITY_PATTERN)
  countedQuantity!: string;
}

export class StockCountCreateDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(500)
  reason!: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(100)
  reference?: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => StockCountLineWriteDto)
  lines!: StockCountLineWriteDto[];
}

export class StockCountListQueryDto {
  @IsOptional()
  @IsUUID()
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}

export class WasteCreateDto {
  @IsUUID()
  stockItemId!: string;

  @IsString()
  @Matches(NON_NEGATIVE_QUANTITY_PATTERN)
  quantity!: string;

  @IsEnum(WasteReason)
  reason!: WasteReason;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(500)
  note?: string;
}

export class WasteListQueryDto {
  @IsOptional()
  @IsUUID()
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}

export class TransferLineWriteDto {
  @IsUUID()
  stockItemId!: string;

  @IsString()
  @Matches(NON_NEGATIVE_QUANTITY_PATTERN)
  quantity!: string;
}

export class TransferCreateDto {
  @IsUUID()
  destinationOutletId!: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(100)
  reference?: string;

  @IsOptional()
  @Transform(trim)
  @IsString()
  @MaxLength(500)
  reason?: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => TransferLineWriteDto)
  lines!: TransferLineWriteDto[];
}

export class TransferListQueryDto {
  @IsOptional()
  @IsEnum(TransferState)
  state?: TransferState;

  @IsOptional()
  @IsUUID()
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}

export class TransferReceiveLineDto {
  @IsUUID()
  lineId!: string;

  @IsString()
  @Matches(NON_NEGATIVE_QUANTITY_PATTERN)
  quantity!: string;
}

export class TransferReceiveDto {
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => TransferReceiveLineDto)
  lines!: TransferReceiveLineDto[];
}
