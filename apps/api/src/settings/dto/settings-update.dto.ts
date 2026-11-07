import { Transform } from 'class-transformer';
import { IsInt, IsNotEmpty, IsString, Matches, Max, MaxLength, Min } from 'class-validator';

const trim = ({ value }: { value: unknown }): unknown =>
  typeof value === 'string' ? value.trim() : value;

export class SettingsUpdateDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  businessName!: string;

  @Transform(trim)
  @IsString()
  @Matches(/^[A-Z]{3}$/)
  currency!: string;

  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  timezone!: string;

  @Transform(trim)
  @IsString()
  @MaxLength(500)
  receiptHeader!: string;

  @Transform(trim)
  @IsString()
  @MaxLength(500)
  receiptFooter!: string;

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
