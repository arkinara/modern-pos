import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsNotEmpty,
  IsString,
  IsUUID,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { trim } from '../../common/transforms';
import { MenuVariantWriteDto } from './menu-variant-write.dto';

export class MenuCreateDto {
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

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(50)
  @ValidateNested({ each: true })
  @Type(() => MenuVariantWriteDto)
  variants!: MenuVariantWriteDto[];
}
