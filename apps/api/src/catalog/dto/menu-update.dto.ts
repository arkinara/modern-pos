import { Transform } from 'class-transformer';
import { IsInt, IsNotEmpty, IsString, IsUUID, MaxLength, Min } from 'class-validator';
import { trim } from '../../common/transforms';

export class MenuUpdateDto {
  @Transform(trim)
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  name!: string;

  @Transform(trim)
  @IsString()
  @MaxLength(2000)
  description!: string;

  @IsUUID()
  categoryId!: string;

  @IsInt()
  @Min(1)
  revision!: number;
}
