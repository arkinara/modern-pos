import { Transform } from 'class-transformer';
import { IsNotEmpty, IsString, IsUUID, Matches, MaxLength, MinLength } from 'class-validator';
import { trim } from '../../common/transforms';
import { NON_NEGATIVE_QUANTITY_PATTERN } from './stock-create.dto';

export class StockChangeDto {
  @IsUUID()
  stockItemId!: string;

  @IsString()
  @Matches(NON_NEGATIVE_QUANTITY_PATTERN)
  quantity!: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(500)
  reason!: string;
}
