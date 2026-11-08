import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsInt,
  IsString,
  IsUUID,
  Matches,
  Min,
  ValidateNested,
} from 'class-validator';
import { trim } from '../../common/transforms';

export const RECIPE_QUANTITY_PATTERN = /^(0|[1-9][0-9]{0,12})(\.[0-9]{1,6})?$/;

export class RecipeLineDto {
  @IsUUID()
  stockItemId!: string;

  @Transform(trim)
  @IsString()
  @Matches(RECIPE_QUANTITY_PATTERN)
  quantityPerSaleUnit!: string;
}

export class RecipeWriteDto {
  @IsInt()
  @Min(0)
  expectedVersion!: number;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @ValidateNested({ each: true })
  @Type(() => RecipeLineDto)
  lines!: RecipeLineDto[];
}
