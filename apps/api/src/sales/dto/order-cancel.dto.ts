import { IsInt, Min } from 'class-validator';

export class OrderCancelDto {
  @IsInt()
  @Min(1)
  version!: number;
}
