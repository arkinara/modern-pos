import { Type } from 'class-transformer';
import { ArrayMaxSize, IsArray, IsUUID, ValidateNested } from 'class-validator';

export class StationRouteEntryDto {
  @IsUUID()
  menuItemId!: string;

  @IsUUID()
  stationId!: string;
}

export class StationRoutingWriteDto {
  @IsArray()
  @ArrayMaxSize(500)
  @ValidateNested({ each: true })
  @Type(() => StationRouteEntryDto)
  routes!: StationRouteEntryDto[];
}
