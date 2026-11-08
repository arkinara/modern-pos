import { IsUUID } from 'class-validator';

export class CheckoutQueryDto {
  @IsUUID('4')
  deviceId!: string;
}
