import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { trim } from '../../common/transforms';

export const FIXED_POINT_PATTERN = /^(0|[1-9][0-9]{0,12})(\.[0-9]{1,6})?$/;

export class RestockItemDto {
  @IsUUID()
  stockItemId!: string;

  @IsString()
  @Matches(FIXED_POINT_PATTERN, {
    message: 'quantity must be a nonnegative fixed-point base-unit string',
  })
  quantity!: string;
}

export class ReversalDto {
  @Transform(trim)
  @IsString()
  @MinLength(3)
  @MaxLength(500)
  reason!: string;

  @IsArray()
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => RestockItemDto)
  restock!: RestockItemDto[];
}
