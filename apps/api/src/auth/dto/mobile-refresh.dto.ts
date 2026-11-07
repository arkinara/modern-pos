import { IsString, IsUUID, MaxLength, MinLength } from 'class-validator';

export class MobileRefreshDto {
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  refreshToken!: string;

  @IsUUID('4')
  deviceId!: string;
}
