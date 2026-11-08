import { Type } from 'class-transformer';
import { IsUUID, ValidateNested } from 'class-validator';
import { PaymentInputDto } from './payment-input.dto';

export class FinalizeDto {
  @IsUUID('4')
  deviceId!: string;

  @IsUUID()
  orderId!: string;

  @IsUUID()
  quoteId!: string;

  @ValidateNested()
  @Type(() => PaymentInputDto)
  payment!: PaymentInputDto;
}
