import { IsInt, IsNotEmpty, IsString, Max, MaxLength, Min } from 'class-validator';

export class OutletUpdateDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  name!: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  timezone!: string;

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
