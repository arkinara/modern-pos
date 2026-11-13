import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, IsString, IsUUID, Max, Min } from 'class-validator';
import { STATION_JOB_STATES, type StationJobStateValue } from './station-job-write.dto';

export class StationJobListQueryDto {
  @IsOptional()
  @IsString()
  @IsIn(STATION_JOB_STATES)
  state?: StationJobStateValue;

  @IsOptional()
  @IsUUID()
  cursor?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;
}
