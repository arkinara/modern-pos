import { Transform } from 'class-transformer';
import { IsInt, IsNotEmpty, IsString, Max, MaxLength, Min } from 'class-validator';
import { TIMEZONE_VALIDATION_MESSAGE, IsValidTimeZone } from '../../common/timezone';
import { trim } from '../../common/transforms';

export class OutletUpdateDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  name!: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  @IsValidTimeZone({ message: TIMEZONE_VALIDATION_MESSAGE })
  timezone!: string;

  @Transform(trim)
  @IsString()
  @MaxLength(1000)
  receiptAddress!: string;

  @IsInt()
  @Min(0)
  @Max(10_000)
  taxBps!: number;

  @IsInt()
  @Min(0)
  @Max(10_000)
  serviceBps!: number;

  @IsInt()
  @Min(1)
  version!: number;
}
