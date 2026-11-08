import { IsInt, Min } from 'class-validator';

export class QuoteCreateDto {
  @IsInt()
  @Min(1)
  orderVersion!: number;
}
