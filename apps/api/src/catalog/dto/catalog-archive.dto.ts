import { IsInt, Min } from 'class-validator';

export class CatalogArchiveDto {
  @IsInt()
  @Min(1)
  revision!: number;
}
