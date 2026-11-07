import { IsUUID } from 'class-validator';
import { WebLoginDto } from './web-login.dto';

export class MobileLoginDto extends WebLoginDto {
  @IsUUID('4')
  deviceId!: string;
}
