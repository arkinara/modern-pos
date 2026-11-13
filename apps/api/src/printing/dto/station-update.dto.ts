import { IsInt, Min } from 'class-validator';
import { StationWriteDto } from './station-write.dto';

export class StationUpdateDto extends StationWriteDto {
  @IsInt()
  @Min(1)
  revision!: number;
}
