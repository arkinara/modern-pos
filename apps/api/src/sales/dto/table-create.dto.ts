import { Transform } from 'class-transformer';
import { IsInt, IsOptional, IsString, Max, MaxLength, Min, MinLength } from 'class-validator';
import { trim } from '../../common/transforms';

export class TableCreateDto {
  @Transform(trim)
  @IsString()
  @MinLength(1)
  @MaxLength(60)
  label!: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  seatCount?: number;
}
