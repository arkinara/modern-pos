import { Transform } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsEmail,
  IsInt,
  IsOptional,
  IsUUID,
  MaxLength,
  Min,
} from 'class-validator';
import { trim } from '../../common/transforms';

export class QuoteCreateDto {
  @IsInt()
  @Min(1)
  orderVersion!: number;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(20)
  @IsUUID('4', { each: true })
  promotionIds?: string[];

  @IsOptional()
  @Transform(trim)
  @IsEmail()
  @MaxLength(200)
  customerEmail?: string;
}
