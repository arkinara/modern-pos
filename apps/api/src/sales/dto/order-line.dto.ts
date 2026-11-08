import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsInt,
  IsUUID,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';

export class OrderLineDto {
  @IsUUID()
  variantId!: string;

  @IsInt()
  @Min(1)
  @Max(100_000)
  quantity!: number;
}
